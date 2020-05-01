import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class OnboardView extends StatelessWidget {
  const OnboardView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: RaisedButton(
          child: Text('First launch check'),
          onPressed: () async {
            final mscData = await Hive.openBox('miscellaneous');
            await mscData.put('first_launch', false);
            Navigator.pushNamed(context, '/mainview');
          },
        ),
      ),
    );
  }
}