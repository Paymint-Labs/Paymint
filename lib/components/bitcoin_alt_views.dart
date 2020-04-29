import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget displayed in place of BitcoinView while fetching data from API
class BitcoinViewLoading extends StatefulWidget {
  BitcoinViewLoading({Key key}) : super(key: key);

  @override
  _BitcoinViewLoadingState createState() => _BitcoinViewLoadingState();
}

class _BitcoinViewLoadingState extends State<BitcoinViewLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
    );
  }
}