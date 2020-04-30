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
      body: Center(child: Image.asset('assets/images/mirage-payment-processed.png', scale: 2.99)),
      bottomNavigationBar: Container(
        height: 315,
        child: Column(
          children: <Widget>[
            SizedBox(height: 60),
            Text(
              "We're working to make this as smooth as it can be.",
              textScaleFactor: 1.8,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.lightBlue,
                  height: 60,
                  width: 300,
                  child: Center(
                    child: Text(
                      'Leave a request',
                      textScaleFactor: 1.4,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
            SizedBox(height: 15),
            Text("Leave us some feedback on what\nyou'd like for the product", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
