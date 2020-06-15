import 'dart:typed_data';

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
  Future<dynamic> _bitcoinPrice;
  Future<dynamic> get bitcoinPrice => _bitcoinPrice ??= getBitcoinPrice();

  Future<FeeObject> _feeObject;
  Future<FeeObject> get fees => _feeObject ??= getFees();

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
      _feeObject = getFees();
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
    final initialReceivingAddress = await generateAddressForChain(0, 0);
    final initialChangeAddress = await generateAddressForChain(1, 0);
    await addToAddressesArrayForChain(initialReceivingAddress, 0);
    await addToAddressesArrayForChain(initialChangeAddress, 1);
    this._currentReceivingAddress = Future(() => initialReceivingAddress);
  }

  /// Generates a new internal or external chain address for the wallet using a BIP84 derivation path.
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  /// [index] - This can be any integer >= 0
  Future<String> generateAddressForChain(int chain, int index) async {
    final secureStore = new FlutterSecureStorage();
    final seed = bip39.mnemonicToSeed(await secureStore.read(key: 'mnemonic'));
    final root = bip32.BIP32.fromSeed(seed);
    final node = root.derivePath("m/84'/0'/0'/$chain/$index");

    return P2WPKH(data: new PaymentData(pubkey: node.publicKey)).data.address;
  }

  /// Increases the index for either the internal or external chain, depending on [chain].
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  Future<void> incrementAddressIndexForChain(int chain) async {
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
  Future<void> addToAddressesArrayForChain(String address, int chain) async {
    final wallet = await Hive.openBox('wallet');
    String chainArray = '';
    if (chain == 0) {
      chainArray = 'receivingAddresses';
    } else {
      chainArray = 'changeAddresses';
    }

    final addressArray = wallet.get(chainArray);
    if (addressArray == null) {
      print('Attempting to add the following to array for chain $chain:' +
          [address].toString());
      await wallet.put(chainArray, [address]);
    } else {
      // Make a deep copy of the exisiting list
      final newArray = new List<String>();
      addressArray.forEach((_address) => newArray.add(_address));
      newArray.add(address); // Add the address passed into the method
      await wallet.put(chainArray, newArray);
    }
  }

  /// Returns the latest receiving/change (external/internal) address for the wallet depending on [chain]
  /// [chain] - Use 0 for receiving (external), 1 for change (internal). Should not be any other value!
  Future<String> _getCurrentAddressForChain(int chain) async {
    final wallet = await Hive.openBox('wallet');
    if (chain == 0) {
      final externalChainArray = await wallet.get('receivingAddresses');
      return externalChainArray.last;
    } else {
      // Here, we assume that chain == 1
      final internalChainArray = await wallet.get('changeAddresses');
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
    final dynamic newBtcPrice = await getBitcoinPrice();
    final FeeObject feeObj = await getFees();
    await checkReceivingAddressForTransactions();

    this._utxoData = Future(() => newUtxoData);
    this._transactionData = Future(() => newTxData);
    this._bitcoinPrice = Future(() => newBtcPrice);
    this._feeObject = Future(() => feeObj);
    notifyListeners();
  }

  changeCurrency(String newCurrency) async {
   final prefs = await Hive.openBox('prefs');
   await prefs.put('currency', newCurrency);
   this._currency = Future(() => newCurrency);
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

  coinSelection(int satoshiAmountToSend,
      dynamic selectedTxFee, String _recipientAddress) async {
    final List<UtxoObject> availableOutputs = this.allOutputs;
    final List<UtxoObject> spendableOutputs = new List();
    int spendableSatoshiValue = 0;

    // Build list of spendable outputs and totaling their satoshi amount
    for (var i = 0; i < availableOutputs.length; i++) {
      if (availableOutputs[i].blocked == false &&
          availableOutputs[i].status.confirmed == true) {
        spendableOutputs.add(availableOutputs[i]);
        spendableSatoshiValue += availableOutputs[i].value;
      }
    }

    // If the amount the user is trying to send is smaller than the amount that they have spendable,
    // then return 1, which indicates that they have an insufficient balance.
    if (spendableSatoshiValue < satoshiAmountToSend) {
      return 1;
      // If the amount the user wants to send is exactly equal to the amount they can spend, then return
      // 2, which indicates that they are not leaving enough over to pay the transaction fee
    } else if (spendableSatoshiValue == satoshiAmountToSend) {
      return 2;
    }
    // If neither of these statements pass, we assume that the user has a spendable balance greater
    // than the amount they're attempting to send. Note that this value still does not account for
    // the added transaction fee, which may require an extra input and will need to be checked for
    // later on.

    int satoshisBeingUsed = 0;
    int inputsBeingConsumed = 0;
    List<UtxoObject> utxoObjectsToUse = new List();

    while (satoshisBeingUsed < satoshiAmountToSend) {
      for (var i = 0; i < spendableOutputs.length; i++) {
        utxoObjectsToUse.add(spendableOutputs[i]);
        satoshisBeingUsed += spendableOutputs[i].value;
        inputsBeingConsumed += 1;
      }
    }

    // numberOfOutputs' length must always be equal to that of recipientsArray and recipientsAmtArray
    List<String> recipientsArray = [_recipientAddress];
    List<int> recipientsAmtArray = [satoshiAmountToSend];

    // Assume 1 output, only for recipient and no change
    final feeForOneOutput =
        ((42 + 272 * inputsBeingConsumed + 128) / 4).ceil() *
            selectedTxFee.ceil();
    // Assume 2 outputs, one for recipient and one for change
    final feeForTwoOutputs =
        ((42 + 272 * inputsBeingConsumed + 128 * 2) / 4).ceil() *
            selectedTxFee.ceil();

    print('Fee for one output: $feeForOneOutput');
    print('Fee for two outputs: $feeForTwoOutputs');

    if (satoshisBeingUsed - satoshiAmountToSend > feeForOneOutput) {
      if (satoshisBeingUsed - satoshiAmountToSend > feeForOneOutput + 293) {
        // Here, we know that theoretically, we may be able to include another output(change) but we first need to
        // factor in the value of this output in satoshis.
        int changeOutputSize =
            satoshisBeingUsed - satoshiAmountToSend - feeForTwoOutputs;
        // We check to see if the user can pay for the new transaction with 2 outputs instead of one. Iff they can and
        // the second output's size > 293 satoshis, we perform the mechanics required to properly generate and use a new
        // change address.
        if (changeOutputSize > 293 &&
            satoshisBeingUsed - satoshiAmountToSend - changeOutputSize ==
                feeForTwoOutputs) {
          await incrementAddressIndexForChain(1);
          final wallet = await Hive.openBox('wallet');
          final int changeIndex = await wallet.get('changeIndex');
          final String newChangeAddress =
              await generateAddressForChain(1, changeIndex);
          await addToAddressesArrayForChain(newChangeAddress, 1);
          recipientsArray.add(newChangeAddress);
          recipientsAmtArray.add(changeOutputSize);
          // At this point, we have the outputs we're going to use, the amounts to send along with which addresses
          // we intend to send these amounts to. We have enough to send instructions to build the transaction.
          print('2 outputs in tx');
          print('Input size: $satoshisBeingUsed');
          print('Recipient output size: $satoshiAmountToSend');
          print('Change Output Size: $changeOutputSize');
          dynamic hex = await buildTransaction(
              utxoObjectsToUse, recipientsArray, recipientsAmtArray);
          Map<String, dynamic> transactionObject = {
            "hex": hex,
            "recipient": recipientsArray[0],
            "recipientAmt": recipientsAmtArray[0],
            "fee": satoshisBeingUsed - satoshiAmountToSend - changeOutputSize
          };
          return transactionObject;
        } else {
          // Something went wrong here. It either overshot or undershot the estimated fee amount or the changeOutputSize
          // is smaller than or equal to 293. Revert to single output transaction.
          print('1 output in tx');
          print('Input size: $satoshisBeingUsed');
          print('Recipient output size: $satoshiAmountToSend');
          print('Difference (fee being paid): ' +
              (satoshisBeingUsed - satoshiAmountToSend).toString() +
              ' sats');
          print('Actual fee: $feeForOneOutput');
          dynamic hex = await buildTransaction(
              utxoObjectsToUse, recipientsArray, recipientsAmtArray);
          Map<String, dynamic> transactionObject = {
            "hex": hex,
            "recipient": recipientsArray[0],
            "recipientAmt": recipientsAmtArray[0],
            "fee": satoshisBeingUsed - satoshiAmountToSend
          };
          return transactionObject;
        }
      } else {
        // No additional outputs needed since adding one would mean that it'd be smaller than 293 sats
        // which makes it uneconomical to add to the transaction. Here, we pass data directly to instruct
        // the wallet to begin crafting the transaction that the user requested.
        print('1 output in tx');
        print('Input size: $satoshisBeingUsed');
        print('Recipient output size: $satoshiAmountToSend');
        print('Difference (fee being paid): ' +
            (satoshisBeingUsed - satoshiAmountToSend).toString() +
            ' sats');
        print('Actual fee: $feeForOneOutput');
        dynamic hex = await buildTransaction(
            utxoObjectsToUse, recipientsArray, recipientsAmtArray);
        Map<String, dynamic> transactionObject = {
          "hex": hex,
          "recipient": recipientsArray[0],
          "recipientAmt": recipientsAmtArray[0],
          "fee": satoshisBeingUsed - satoshiAmountToSend
        };
        return transactionObject;
      }
    } else if (satoshisBeingUsed - satoshiAmountToSend == feeForOneOutput) {
      // In this scenario, no additional change output is needed since inputs - outputs equal exactly
      // what we need to pay for fees. Here, we pass data directly to instruct the wallet to begin
      // crafting the transaction that the user requested.
      print('1 output in tx');
      print('Input size: $satoshisBeingUsed');
      print('Recipient output size: $satoshiAmountToSend');
      print('Fee being paid: ' +
          (satoshisBeingUsed - satoshiAmountToSend).toString() +
          ' sats');
      dynamic hex = await buildTransaction(
          utxoObjectsToUse, recipientsArray, recipientsAmtArray);
      Map<String, dynamic> transactionObject = {
          "hex": hex,
          "recipient": recipientsArray[0],
          "recipientAmt": recipientsAmtArray[0],
          "fee": feeForOneOutput
        };
        return transactionObject;
    } else {
      // Remember that returning 2 indicates that the user does not have a sufficient balance to
      // pay for the transaction fee. Ideally, at this stage, we should check if the user has any
      // additional outputs they're able to spend and then recalculate fees.
      print('Cannot pay tx fee - cancelling transaction');
      return 2;
    }
  }

  Future<dynamic> buildTransaction(List<UtxoObject> utxosToUse,
      List<String> recipients, List<int> satoshisPerRecipient) async {
    List<String> addressesToDerive = new List();

    // Populating the addresses to derive
    for (var i = 0; i < utxosToUse.length; i++) {
      List<dynamic> lookupData = [utxosToUse[i].txid, utxosToUse[i].vout];
      Map<String, dynamic> requestBody = {"lookupData": lookupData};

      final response = await http.post(
        'https://www.api.paymintapp.com/btc/lookup',
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        addressesToDerive.add(json.decode(response.body));
      } else {
        throw Exception('Something happened: ' +
            response.statusCode.toString() +
            response.body);
      }
    }

    final secureStore = new FlutterSecureStorage();
    final seed = bip39.mnemonicToSeed(await secureStore.read(key: 'mnemonic'));
    final root = bip32.BIP32.fromSeed(seed);

    List<ECPair> elipticCurvePairArray = new List();
    List<Uint8List> outputDataArray = new List();

    for (var i = 0; i < addressesToDerive.length; i++) {
      final addressToCheckFor = addressesToDerive[i];

      for (var i = 0; i < 2000; i++) {
        final nodeReceiving = root.derivePath("m/84'/0'/0'/0/$i");
        final nodeChange = root.derivePath("m/84'/0'/0'/1/$i");

        if (P2WPKH(data: new PaymentData(pubkey: nodeReceiving.publicKey))
                .data
                .address ==
            addressToCheckFor) {
          elipticCurvePairArray.add(ECPair.fromWIF(nodeReceiving.toWIF()));
          outputDataArray.add(
              P2WPKH(data: new PaymentData(pubkey: nodeReceiving.publicKey))
                  .data
                  .output);
          break;
        }
        if (P2WPKH(data: new PaymentData(pubkey: nodeChange.publicKey))
                .data
                .address ==
            addressToCheckFor) {
          elipticCurvePairArray.add(ECPair.fromWIF(nodeChange.toWIF()));
          outputDataArray.add(
              P2WPKH(data: new PaymentData(pubkey: nodeChange.publicKey))
                  .data
                  .output);
          break;
        }
      }
    }

    final txb = new TransactionBuilder();
    txb.setVersion(1);

    // Add transaction inputs
    for (var i = 0; i < utxosToUse.length; i++) {
      txb.addInput(
          utxosToUse[i].txid, utxosToUse[i].vout, null, outputDataArray[i]);
    }

    // Add transaction outputs
    for (var i = 0; i < recipients.length; i++) {
      txb.addOutput(recipients[i], satoshisPerRecipient[i]);
    }

    // Sign the transaction accordingly
    for (var i = 0; i < utxosToUse.length; i++) {
      txb.sign(
          vin: 0,
          keyPair: elipticCurvePairArray[i],
          witnessValue: utxosToUse[i].value);
    }
    return txb.build().toHex();
  }

  Future<UtxoData> _fetchUtxoData() async {
    final wallet = await Hive.openBox('wallet');
    final List<String> allAddresses = new List();
    final String currency = await CurrencyUtilities.fetchPreferredCurrency();
    final List receivingAddresses = await wallet.get('receivingAddresses');
    final List changeAddresses = await wallet.get('changeAddresses');

    for (var i = 0; i < receivingAddresses.length; i++) {
      allAddresses.add(receivingAddresses[i]);
    }
    for (var i = 0; i < changeAddresses.length; i++) {
      allAddresses.add(changeAddresses[i]);
    }

    final Map<String, dynamic> requestBody = {
      "currency": currency,
      "allAddresses": allAddresses,
    };

    final response = await http.post(
      'https://www.api.paymintapp.com/btc/outputs',
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

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
    final List<String> allAddresses = new List();
    final String currency = await CurrencyUtilities.fetchPreferredCurrency();
    final List receivingAddresses = await wallet.get('receivingAddresses');
    final List changeAddresses = await wallet.get('changeAddresses');

    for (var i = 0; i < receivingAddresses.length; i++) {
      allAddresses.add(receivingAddresses[i]);
    }
    for (var i = 0; i < changeAddresses.length; i++) {
      allAddresses.add(changeAddresses[i]);
    }

    final Map<String, dynamic> requestBody = {
      "currency": currency,
      "allAddresses": allAddresses,
    };

    final response = await http.post(
      'https://www.api.paymintapp.com/btc/transactions',
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

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

  Future<dynamic> getBitcoinPrice() async {
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

        await incrementAddressIndexForChain(
            0); // First increment the receiving index
        final newReceivingIndex =
            await wallet.get('receivingIndex'); // Check the new receiving index
        final newReceivingAddress = await generateAddressForChain(0,
            newReceivingIndex); // Use new index to derive a new receiving address
        await addToAddressesArrayForChain(newReceivingAddress,
            0); // Add that new receiving address to the array of receiving addresses
        this._currentReceivingAddress = Future(() =>
            newReceivingAddress); // Set the new receiving address that the service
        notifyListeners();
      }
    } else {
      throw Exception('Something happened: ' +
          response.statusCode.toString() +
          response.body);
    }
  }

  Future<FeeObject> getFees() async {
    final response = await http.get('https://www.api.paymintapp.com/btc/fees');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final FeeObject feeObj = FeeObject.fromJson(json.decode(response.body));
      return feeObj;
    } else {
      throw Exception('Something happened: ' +
          response.statusCode.toString() +
          response.body);
    }
  }
}
