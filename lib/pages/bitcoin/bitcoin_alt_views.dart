import 'package:flutter/material.dart';

// This file contains views for 2 alternate states of bitcoin_view widget
// 1) A loading view
// 2) A view for which no transactions or UTXOs are associated with the wallet

/// Widget displayed in place of BitcoinView while fetching data from API
class BitcoinViewLoading extends StatefulWidget {
  BitcoinViewLoading({Key key}) : super(key: key);

  @override
  _BitcoinViewLoadingState createState() => _BitcoinViewLoadingState();
}

class _BitcoinViewLoadingState extends State<BitcoinViewLoading> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Container(),
    );
  }
}

/// Widget displayed when user has either no utxos, 0 zero balance, or both
class BitcoinViewZeroBalance extends StatefulWidget {
  BitcoinViewZeroBalance({Key key}) : super(key: key);

  @override
  _BitcoinViewZeroBalanceState createState() => _BitcoinViewZeroBalanceState();
}

class _BitcoinViewZeroBalanceState extends State<BitcoinViewZeroBalance> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Container(),
    );
  }
}