import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardView extends StatefulWidget {
  const OnboardView({Key key}) : super(key: key);

  @override
  _OnboardViewState createState() => _OnboardViewState();
}

class _OnboardViewState extends State<OnboardView> {
  List<int> initialLock;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: _buildLockPageView(),
      ),
    );
  }

  PageView _buildLockPageView() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: pageController,
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(8),
            height: 200,
            child: ListView(
              children: <Widget>[
                Text(
                  'By continuing, I agree to the Terms of Service.',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'By continuing, I understand that it is my responsibility to secure a physical backup of my seed phrase to ensure against a loss of funds.',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Container(
                  height: 100,
                  child: Center(
                    child: CupertinoButton.filled(
                      onPressed: () {
                        pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text('Continue'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Set a pattern lock for your wallet',
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.3,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: PatternLock(
                selectedColor: Colors.purple,
                dimension: 3,
                notSelectedColor: Colors.white,
                onInputComplete: (List<int> input) {
                  if (input.length < 4) {
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content:
                            Text('Pattern length needs to be at least 4 nodes'),
                      ),
                    );
                  } else {
                    print(input.toString());
                    this.initialLock = input;
                    pageController.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Confirm your pattern lock',
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
                  if (listEquals(input, initialLock) == false) {
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(
                        SnackBar(content: Text('Incorrect pattern')));
                    pageController.animateToPage(0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  } else {
                    final store = new FlutterSecureStorage();
                    await store.write(key: 'lockcode', value: jsonEncode(input));
                    
                    final mscData = await Hive.openBox('miscellaneous');
                    await mscData.put('first_launch', false);
                    
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Lock set'),
                    ));
                    Navigator.pushNamed(context, '/mainview');
                  }
                },
              ),
            )
          ],
        )
      ],
    );
  }
}

/// KEEP THIS HERE FOR NOW
// final mscData = await Hive.openBox('miscellaneous');
// await mscData.put('first_launch', false);
// Navigator.pushNamed(context, '/mainview');
