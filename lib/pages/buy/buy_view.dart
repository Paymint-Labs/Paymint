import 'package:flutter/cupertino.dart';
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
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: CupertinoButton.filled(child: Text('Leave us feedback'), onPressed: () {}),
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/mirage-payment-processed.png', height: 250),
            Text("We're working to make this as\nsmooth as it can be.", textScaleFactor: 1.5, textAlign: TextAlign.center),
            SizedBox(height: 25),
            Text("It'll be ready soon.", textScaleFactor: 1.5, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
