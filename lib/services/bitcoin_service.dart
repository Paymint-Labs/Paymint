import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paymint/models/models.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:paymint/services/utils/currency_map.dart';

class BitcoinService extends ChangeNotifier {
  /// Returns boolean indicating whether or not constructor has completed wallet initialization function
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
  Future<String> get currency => _currency ??= fetchPreferredCurrency();

  /// Holds updated receiving address
  Future<String> _currentReceivingAddress;
  Future<String> get currentReceivingAddress => _currentReceivingAddress; // Not cuurently in constructor

  BitcoinService() {
    this._initializeBitcoinWallet();
    this._initializationStatus = true;
    
    _utxoData = fetchUtxoData(); 
    _transactionData = fetchTransactionData();
    _currency = fetchPreferredCurrency();
  }
  
  /// Checks to see if a Bitcoin Wallet exists, if not it will create one first
  void _initializeBitcoinWallet() async {
    final wallet = await Hive.openBox('wallet');
    if (wallet.isEmpty) {  // Triggers for new users automatically
      final secureStore = new FlutterSecureStorage();
      final mnemonic = bip39.generateMnemonic();
      await secureStore.write(key: 'mnemonic', value: mnemonic);  // Write a new mnemonic to secure element when Hive finds empty wallet
      wallet.put('receivingIndex', 0);  // Set receiving address index
      wallet.put('changeIndex', 0);  // Set change address index
      // Generate addresses from indexes above and add them to Hive arrays

    } else {  // Wallet already exists

    }
  }

  /// Fetches the preferred currency by user, defaults to USD
  Future<String> fetchPreferredCurrency() async {
    final prefs = await Hive.openBox('prefs');
    if (prefs.isEmpty) {
      await prefs.put('currency', 'USD');
      return 'USD';
    } else {
      return await prefs.get('currency');
    }
  }

  /// This function assumes that there is already a valid mnemonic in the secure element under the key 'mnemonic'
  Future<String> generateReceivingAddress(int index) async {
    final secureStore = new FlutterSecureStorage();
    final seed = bip39.mnemonicToSeed(await secureStore.read(key: 'mnemonic'));
    final root = bip32.BIP32.fromSeed(seed);
    final node = root.derivePath("m/84'/0'/0'/0/$index");
    
    return P2WPKH(data: new PaymentData(pubkey: node.publicKey)).data.address;
  }

  void incrementReceivingIndex() async {
    final wallet = await Hive.openBox('wallet');
    final newIndex = wallet.get('receivingIndex') + 1;
    await wallet.put('receivingIndex', newIndex);
  }

  Future<String> generateChangeAddress(int index) async {
    final secureStore = new FlutterSecureStorage();
    final seed = bip39.mnemonicToSeed(await secureStore.read(key: 'mnemonic'));
    final root = bip32.BIP32.fromSeed(seed);
    final node = root.derivePath("m/84'/0'/0'/1/$index");

    return P2WPKH(data: new PaymentData(pubkey: node.publicKey)).data.address;
  }

  void incrementChangeIndex() {

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
