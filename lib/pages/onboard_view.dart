import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class OnBoard extends StatelessWidget {
  const OnBoard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: RaisedButton(
          child: Text('First launch check'),
          onPressed: () async {
            final mscData = await Hive.openBox('miscellaneous');
            mscData.put('first_launch', false);
          },
        ),
      ),
    );
  }
}