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

class BitcoinService extends ChangeNotifier {
  /// Returns boolean indicating whether or not constructor has completed wallet initialization method
  bool _initializationStatus = false;
  bool get initializationStatus => _initializationStatus;

  /// Holds final balances, all utxos under control 
  Future<UtxoData> _utxoData;
  Future<UtxoData> get utxoData => _utxoData ??= fetchUtxoData();

  /// Holds wallet transaction data
  Future<TransactionData> _transactionData;
  Future<TransactionData> get transactionData => _transactionData ??= fetchTransactionData();

  /// Holds preferred fiat currency
  Future<String> _currency;
  Future<String> get currency => _currency ??= CurrencyUtilities.fetchPreferredCurrency();

  /// Holds updated receiving address
  Future<String> _currentReceivingAddress;
  Future<String> get currentReceivingAddress => _currentReceivingAddress;

  BitcoinService() {
    this._initializeBitcoinWallet();
    _currency = CurrencyUtilities.fetchPreferredCurrency();
    this._initializationStatus = true;
    
    _utxoData = fetchUtxoData(); 
    _transactionData = fetchTransactionData();
  }
  
  /// Checks to see if a Bitcoin Wallet exists, if not it will create one first
  void _initializeBitcoinWallet() async {
    final wallet = await Hive.openBox('wallet');
    if (wallet.isEmpty) {  // Triggers for new users automatically
      this.generateNewWallet(wallet);
    } else {  // Wallet already exists, returning user

    }
  }

  Future<void> generateNewWallet(Box wallet) async {
    final secureStore = new FlutterSecureStorage();
    final mnemonic = bip39.generateMnemonic();
    await secureStore.write(key: 'mnemonic', value: mnemonic);  // Write a new mnemonic to secure element when Hive finds empty wallet
    wallet.put('receivingIndex', 0);  // Set receiving address index
    wallet.put('changeIndex', 0);
  }

  /// Generates a new internal or external chain address for the wallet using a BIP84 derivation path.
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  /// [index] - This can be any integer >= 0
  Future<String> generateAddress(int chain, int index) async {
    final secureStore = new FlutterSecureStorage();
    final seed = bip39.mnemonicToSeed(await secureStore.read(key: 'mnemonic'));
    final root = bip32.BIP32.fromSeed(seed);
    final node = root.derivePath("m/84'/0'/0'/$chain/$index");
    
    return P2WPKH(data: new PaymentData(pubkey: node.publicKey)).data.address;
  }

  /// Increases the index for either the internal or external chain, depending on [chain].
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  void incrementAddressIndex(int chain) async {
    final wallet = await Hive.openBox('wallet');
    if (chain == 0) {
      final newIndex = wallet.get('receivingIndex') + 1;
      await wallet.put('receivingIndex', newIndex);
    } else { // Here we assume chain == 1 since it can only be either 0 or 1
      final newIndex = wallet.get('changeIndex') + 1;
      await wallet.put('changeIndex', newIndex);
    }
  }
  
  /// Adds [address] to the relevant chain's address array, which is determined by [chain].
  /// [address] - Expects a standard native segwit address
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  Future<void> addToAddressesArray(String address, int chain) async {
    final wallet = await Hive.openBox('wallet');
    String chainArray = '';
    if (chain == 0) {
      chainArray = 'receivingAddresses';
    } else {
      chainArray = 'changeAddresses';
    }

    final List<String> receivingAddressArray = wallet.get(chainArray);
    if (receivingAddressArray == null) {
      await wallet.put(chainArray, [address]);
    } else {
      // Make a deep copy of the exisiting list 
      final newArray = new List<String>();
      receivingAddressArray.forEach((_address) => {newArray.add(_address)});
      newArray.add(address);  // Add the address passed into the method
      await wallet.put(chainArray, newArray);
    }
  }

  Future<UtxoData> fetchUtxoData() async {
    final requestBody = {
      "currency": "USD",
      "receivingAddresses": ["1PUhivT8B4scmLauhEikMDustjmTACFAtb"],
      "internalAndChangeAddressArray": ["1PUhivT8B4scmLauhEikMDustjmTACFAtb"]
    };

    final response = await http.post('https://www.api.paymintapp.com/btc/outputs', body: jsonEncode(requestBody), headers: {'Content-Type': 'application/json'} );

    if (response.statusCode == 200 || response.statusCode == 201) {
      notifyListeners();
      return UtxoData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something happened: ' + response.statusCode.toString() + response.body );
    }
  }

  Future<TransactionData> fetchTransactionData() async {
    final requestBody = {
      "currency": "USD",
      "receivingAddresses": ["bc1q5jf6r77vhdd4t54xmzgls823g80pz9d9k73d2r"],
      "internalAndChangeAddressArray": ["bc1q5jf6r77vhdd4t54xmzgls823g80pz9d9k73d2r"]
    };

    final response = await http.post('https://www.api.paymintapp.com/btc/transactions', body: jsonEncode(requestBody), headers: {'Content-Type': 'application/json'} );

    if (response.statusCode == 200 || response.statusCode == 201) {
      notifyListeners();
      return TransactionData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something happened: ' + response.statusCode.toString() + response.body );
    }
  }

}
