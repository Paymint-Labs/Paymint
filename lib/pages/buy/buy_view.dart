import 'package:flutter/material.dart';

class BuyView extends StatefulWidget {
  BuyView({Key key}) : super(key: key);

  @override
  _BuyViewState createState() => _BuyViewState();
}

class _BuyViewState extends State<BuyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset('assets/images/work-in-progress.png')
        ),
      ),
    );
  }
}
