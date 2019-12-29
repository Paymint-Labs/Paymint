/**
 * ListTile Widgets for the Activity View.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendListTile extends StatelessWidget {
  const SendListTile(
      {Key key, this.amount, this.currentValue, this.previousValue})
      : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Icon(Icons.keyboard_arrow_up, color: Colors.pink, size: 40),
      title: Text(
        'Sent',
        style: GoogleFonts.rubik(),
      ),
      subtitle: Text(
        amount + ' BTC',
        style: GoogleFonts.rubik(),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            '\$' + previousValue + ' when sent',
            style: GoogleFonts.rubik(),
          ),
          Text(
            '\$' + currentValue + ' now',
            style: GoogleFonts.rubik(),
          ),
        ],
      ),
    );
  }
}

class ReceiveListTile extends StatelessWidget {
  const ReceiveListTile(
      {Key key, this.amount, this.currentValue, this.previousValue})
      : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading:
          Icon(Icons.keyboard_arrow_down, color: Colors.blueAccent, size: 40),
      title: Text(
        'Received',
        style: GoogleFonts.rubik(),
      ),
      subtitle: Text(
        amount + ' BTC',
        style: GoogleFonts.rubik(),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            '\$' + previousValue + ' when received',
            style: GoogleFonts.rubik(),
          ),
          Text(
            '\$' + currentValue + ' now',
            style: GoogleFonts.rubik(),
          ),
        ],
      ),
    );
  }
}

class PurchaseListTile extends StatelessWidget {
  const PurchaseListTile(
      {Key key, this.purchaseAmount, this.valueAtTimeOfPurchase})
      : super(key: key);

  final String purchaseAmount; // Denominated in BTC
  final String
      valueAtTimeOfPurchase; // USD value of purchaseAmount at the time of the purchase

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Icon(
        Icons.show_chart,
        color: Colors.black,
        size: 30,
      ),
      title: Text(
        'Purchased ',
        style: GoogleFonts.rubik(),
      ),
      subtitle: Text(
        purchaseAmount + ' BTC',
        style: GoogleFonts.rubik(),
      ),
      trailing: Text(
        '\$' + valueAtTimeOfPurchase + ' when bought',
        style: GoogleFonts.rubik(),
      ),
    );
  }
}
