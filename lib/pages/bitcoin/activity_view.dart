import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paymint/components/list_tile_components.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ActivityView extends StatefulWidget {
  ActivityView({Key key}) : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        children: <Widget>[
          SizedBox(height: 10),
          Center(child: CupertinoButton.filled(child: Text('Open security manager'), onPressed: () {})),
          SizedBox(height: 20),
          ActiveOutputTile(name: 'Output #1', currentValue: '\$79.21', blockHeight: '29/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "KYC'd output", currentValue: '\$219.21', blockHeight: '03/03/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
          SizedBox(
            height: 10,
          ),
          ActiveOutputTile(name: "Dinner with Jenny", currentValue: '\$719.55', blockHeight: '21/02/2020'),
        ],
      ),
    );
  }
}
