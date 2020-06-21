import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pattern_lock/pattern_lock.dart';
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
          bottomNavigationBar: Container(
            height: 300,
            color: Colors.redAccent,
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
                      SnackBar(content: Text('Pattern length needs to be at least 4 nodes'))
                    );
                  } else {
                    this.initialLock = input;
                    pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
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
                onInputComplete: (List<int> input) {
                  if (listEquals(input, initialLock)) {
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(
                      SnackBar(content: Text('Incorrect pattern'))
                    );
                    pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  } else {
                    final store = new FlutterSecureStorage();
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
