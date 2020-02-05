import 'package:flutter/material.dart';

class BitcoinService extends ChangeNotifier{
  /// This class is the main workhorse of the Paymint client. It handles several critical operations such as:
  /// - Internal accounting (BIP84 - HD Wallet structure for Native Segwit addresses)
  /// - Fetching wallet data from the Paymint API
  /// - Managing private keys

  // Constructor function
  BitcoinService();
}