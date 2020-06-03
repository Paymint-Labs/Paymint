import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:paymint/services/services.dart';

class MoreView extends StatefulWidget {
  MoreView({Key key}) : super(key: key);

  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            height: 200,
            color: Colors.redAccent
          ),
          ListTile(
            title: Text('Security', textScaleFactor: 1.1),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}