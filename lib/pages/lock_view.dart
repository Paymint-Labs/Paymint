import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LockscreenView extends StatefulWidget {
  LockscreenView({Key key}) : super(key: key);

  @override
  _LockscreenViewState createState() => _LockscreenViewState();
}

class _LockscreenViewState extends State<LockscreenView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Draw pattern to unlock',
            style: TextStyle(color: Colors.white),
            textScaleFactor: 1.3,
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: PatternLock(
                selectedColor: Colors.purple,
                dimension: 3,
                notSelectedColor: Colors.white,
                onInputComplete: (List<int> input) async {
                  final store = new FlutterSecureStorage();
                  final String pattern = await store.read(key: 'lockcode');
                  final List patternListJson = jsonDecode(pattern);
                  List<int> actual = new List();
                  for (var i = 0; i < patternListJson.length; i++) {
                    actual.add(patternListJson[i]);
                  }
                  if (listEquals(actual, input)) {
                    Navigator.pushNamed(context, '/mainview');
                  } else {
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Incorrect pattern. Try again.')));
                  }
                }),
          )
        ],
      ),
    );
  }
}
