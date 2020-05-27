import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paymint/models/models.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:paymint/services/utils/currency_utils.dart';
import 'package:paymint/services/utils/dev_utils.dart';

class BitcoinService extends ChangeNotifier {
  /// Returns boolean indicating whether or not constructor has completed wallet initialization method
  Future<bool> _initializationStatus;
  Future<bool> get initializationStatus => _initializationStatus;

  /// Holds final balances, all utxos under control
  Future<UtxoData> _utxoData;
  Future<UtxoData> get utxoData => _utxoData ??= _fetchUtxoData();

  /// Holds wallet transaction data
  Future<TransactionData> _transactionData;
  Future<TransactionData> get transactionData =>
      _transactionData ??= _fetchTransactionData();

  // Hold the current price of Bitcoin in the currency specified in parameter below
  Future<double> _bitcoinPrice;
  Future<double> get bitcoinPrice => _bitcoinPrice ??= getBitcoinPrice();

  /// Holds preferred fiat currency
  Future<String> _currency;
  Future<String> get currency =>
      _currency ??= CurrencyUtilities.fetchPreferredCurrency();

  /// Holds updated receiving address
  Future<String> _currentReceivingAddress;
  Future<String> get currentReceivingAddress => _currentReceivingAddress;

  /// Holds all active outputs for wallet, used for displaying utxos in app security view
  List<UtxoObject> _outputsList = [];
  List<UtxoObject> get allOutputs => _outputsList;

  BitcoinService() {
    _currency = CurrencyUtilities.fetchPreferredCurrency();
    _initializeBitcoinWallet().whenComplete(() {
      _transactionData = _fetchTransactionData();
      _utxoData = _fetchUtxoData();
      _bitcoinPrice = getBitcoinPrice();
    }).whenComplete(() => checkReceivingAddressForTransactions());
  }

  /// Initializes the user's wallet and sets class getters. Will create a wallet if one does not
  /// already exist.
  Future<void> _initializeBitcoinWallet() async {
    final wallet = await Hive.openBox('wallet');
    if (wallet.isEmpty) {
      // Triggers for new users automatically. Generates wallet and defaults currency to 'USD'
      await _generateNewWallet(wallet);
      await DevUtilities.debugPrintWalletState();
    } else {
      // Wallet alreiady exists, triggers for a returning user
      _currentReceivingAddress = this._getCurrentAddressForChain(0);
      DevUtilities.debugPrintWalletState();
    }
  }

  /// Generates initial wallet values such as mnemonic, chain (receive/change) arrays and indexes.
  Future<void> _generateNewWallet(Box<dynamic> wallet) async {
    final secureStore = new FlutterSecureStorage();
    await secureStore.write(key: 'mnemonic', value: bip39.generateMnemonic());
    // Set relevant indexes
    await wallet.put('receivingIndex', 0);
    await wallet.put('changeIndex', 0);
    await wallet.put('phys_backup', false);
    await wallet.put('cloud_backup', false);
    await wallet.put('blocked_tx_hashes', [
      "0xdefault"
    ]); // A list of transaction hashes to represent frozen utxos in wallet
    // Generate and add addresses to relevant arrays
    final initialReceivingAddress = await _generateAddressForChain(0, 0);
    final initialChangeAddress = await _generateAddressForChain(1, 0);
    await _addToAddressesArrayForChain(initialReceivingAddress, 0);
    await _addToAddressesArrayForChain(initialChangeAddress, 1);
    this._currentReceivingAddress = Future(() => initialReceivingAddress);
  }

  /// Generates a new internal or external chain address for the wallet using a BIP84 derivation path.
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  /// [index] - This can be any integer >= 0
  Future<String> _generateAddressForChain(int chain, int index) async {
    final secureStore = new FlutterSecureStorage();
    final seed = bip39.mnemonicToSeed(await secureStore.read(key: 'mnemonic'));
    final root = bip32.BIP32.fromSeed(seed);
    final node = root.derivePath("m/84'/0'/0'/$chain/$index");

    return P2WPKH(data: new PaymentData(pubkey: node.publicKey)).data.address;
  }

  /// Increases the index for either the internal or external chain, depending on [chain].
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  Future<void> _incrementAddressIndexForChain(int chain) async {
    final wallet = await Hive.openBox('wallet');
    if (chain == 0) {
      final newIndex = wallet.get('receivingIndex') + 1;
      await wallet.put('receivingIndex', newIndex);
    } else {
      // Here we assume chain == 1 since it can only be either 0 or 1
      final newIndex = wallet.get('changeIndex') + 1;
      await wallet.put('changeIndex', newIndex);
    }
  }

  /// Adds [address] to the relevant chain's address array, which is determined by [chain].
  /// [address] - Expects a standard native segwit address
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  Future<void> _addToAddressesArrayForChain(String address, int chain) async {
    final wallet = await Hive.openBox('wallet');
    String chainArray = '';
    if (chain == 0) {
      chainArray = 'receivingAddresses';
    } else {
      chainArray = 'changeAddresses';
    }

    final receivingAddressArray = wallet.get(chainArray);
    if (receivingAddressArray == null) {
      print('Attempting to add the following to array for chain $chain:' +
          [address].toString());
      await wallet.put(chainArray, [address]);
    } else {
      // Make a deep copy of the exisiting list
      final newArray = new List<String>();
      receivingAddressArray.forEach((_address) => newArray.add(_address));
      newArray.add(address); // Add the address passed into the method
      await wallet.put(chainArray, newArray);
    }
  }

  /// Returns the latest receiving/change (external/internal) address for the wallet depending on [chain]
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  Future<String> _getCurrentAddressForChain(int chain) async {
    final wallet = await Hive.openBox('wallet');
    if (chain == 0) {
      final externalChainArray = wallet.get('receivingAddresses');
      return externalChainArray.last;
    } else {
      // Here, we assume that chain == 1
      final internalChainArray = wallet.get('changeAddresses');
      return internalChainArray.last;
    }
  }

  void blockOutput(String txid) {
    for (var i = 0; i < allOutputs.length; i++) {
      if (allOutputs[i].txid == txid) {
        allOutputs[i].blocked = true;
        notifyListeners();
      }
    }
  }

  void unblockOutput(String txid) {
    for (var i = 0; i < allOutputs.length; i++) {
      if (allOutputs[i].txid == txid) {
        allOutputs[i].blocked = false;
        notifyListeners();
      }
    }
  }

  refreshWalletData() async {
    final UtxoData newUtxoData = await _fetchUtxoData();
    final TransactionData newTxData = await _fetchTransactionData();
    final double newBtcPrice = await getBitcoinPrice();
    await checkReceivingAddressForTransactions();

    this._utxoData = Future(() => newUtxoData);
    this._transactionData = Future(() => newTxData);
    this._bitcoinPrice = Future(() => newBtcPrice);
    notifyListeners();
  }

  _sortOutputs(List<UtxoObject> utxos) async {
    final wallet = await Hive.openBox('wallet');
    final blockedHashArray = wallet.get('blocked_tx_hashes');
    final lst = new List();
    blockedHashArray.forEach((hash) => lst.add(hash));

    this._outputsList = [];

    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].status.confirmed == false) {
        utxos[i].txName = 'Output $i';
        this._outputsList.add(utxos[i]);
      } else {
        if (lst.contains(utxos[i].txid)) {
          utxos[i].blocked = true;
          utxos[i].txName = 'Output #$i';
          this._outputsList.add(utxos[i]);
        } else if (!lst.contains(utxos[i].txid)) {
          utxos[i].txName = 'Output #$i';
          this._outputsList.add(utxos[i]);
        }
      }
    }
    notifyListeners();
  }

  Future<UtxoData> _fetchUtxoData() async {
    final wallet = await Hive.openBox('wallet');

    final requestBody = {
      "currency": "USD",
      "allAddresses": ["18SYGM2qzCyrvP3MpEV3in5hTYko87MTbK"],
    };

    final response = await http.post(
        'https://www.api.paymintapp.com/btc/outputs',
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('utxo call done');
      final List<UtxoObject> allOutputs =
          UtxoData.fromJson(json.decode(response.body)).unspentOutputArray;
      await _sortOutputs(allOutputs);
      notifyListeners();
      return UtxoData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something happened: ' +
          response.statusCode.toString() +
          response.body);
    }
  }

  Future<TransactionData> _fetchTransactionData() async {
    final wallet = await Hive.openBox('wallet');

    final requestBody = {
      "currency": 'USD',
      "allAddresses": ["18SYGM2qzCyrvP3MpEV3in5hTYko87MTbK"],
    };

    final response = await http.post(
        'https://www.api.paymintapp.com/btc/transactions',
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('tx call done');
      notifyListeners();
      return TransactionData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something happened: ' +
          response.statusCode.toString() +
          response.body);
    }
  }

  Future<double> getBitcoinPrice() async {
    final String currency = await CurrencyUtilities.fetchPreferredCurrency();

    final Map<String, String> requestBody = {"currency": currency};

    final response = await http.post(
      'https://www.api.paymintapp.com/btc/price',
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      notifyListeners();
      print('Current BTC Price: ' + response.body.toString());
      return json.decode(response.body);
    } else {
      throw Exception('Something happened: ' +
          response.statusCode.toString() +
          response.body);
    }
  }

  Future<void> checkReceivingAddressForTransactions() async {
    final String currentExternalAddr = await this._getCurrentAddressForChain(0);
    final Map<String, String> requestBody = {"address": currentExternalAddr};

    final response = await http.post(
      'https://www.api.paymintapp.com/btc/numtxs',
      body: json.encode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final int numtxs = json.decode(response.body);
      print('Number of txs for current receiving addr: ' + numtxs.toString());

      if (numtxs >= 1) {
        final wallet = await Hive.openBox('wallet');

        await _incrementAddressIndexForChain(0);
        final newReceivingIndex = await wallet.get('receivingIndex');
        final newReceivingAddress = await _generateAddressForChain(0, newReceivingIndex);
        await _addToAddressesArrayForChain(newReceivingAddress, 0);
        this._currentReceivingAddress = Future(() => newReceivingAddress);
        notifyListeners();
      }
    }
  }
}
