import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paymint/models/models.dart';

class BitcoinService extends ChangeNotifier {
  /// This class is the main workhorse of the Paymint client. It handles several critical operations such as:
  /// - Internal accounting (BIP84 - HD Wallet structure for Native Segwit addresses)
  /// - Fetching wallet data from the Paymint API
  /// - Managing private keys

  Future<UtxoData> _utxoData;
  Future<UtxoData> get utxoData => _utxoData ??= fetchUtxoData();

  // Constructor function
  BitcoinService() {
    _utxoData = fetchUtxoData();
  }

  Future<UtxoData> fetchUtxoData() async {
    final requestBody = {
      "currency": "USD",
      "receivingAddresses": ["3KHPDaQPxUGWsmB6ik91UWRnuzFz5akCzz"],
      "internalAndChangeAddressArray": ["3KHPDaQPxUGWsmB6ik91UWRnuzFz5akCzz"]
    };

    final response = await http.post('https://www.api.paymintapp.com/mock/outputs', body: requestBody);

    if (response.statusCode == 200) {
      print('success');
      notifyListeners();
      return UtxoData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Something happened: ' + response.statusCode.toString());
    }
  }
}
