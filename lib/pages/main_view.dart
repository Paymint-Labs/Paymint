import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paymint/pages/pages.dart';
import 'package:animations/animations.dart';
import 'package:connectivity/connectivity.dart';

import 'package:paymint/components/bitcoin_alt_views.dart';

/// MainView refers to the main tab bar navigation and view system in place
class MainView extends StatefulWidget {
  MainView({Key key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  List<Widget> children = [BitcoinView(), BuyView(), MoreView()];

  // Tab icon color based on tab selection
  Color _buildIconColor(int index) {
    if (index == this._currentIndex) {
      return Colors.black;
    } else {
      return Colors.grey;
    }
  }

  // Tab text color based on tab selection
  TextStyle _buildTextStyle(int index) {
    if (index == this._currentIndex) {
      return GoogleFonts.rubik(textStyle: TextStyle(color: Colors.black));
    } else {
      return GoogleFonts.rubik(textStyle: TextStyle(color: Colors.grey));
    }
  }

  void _setCurrentIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        Navigator.pushNamed(context, '/404');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _setCurrentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/btc.png',
                height: 24.0,
                width: 24.0,
                color: _buildIconColor(0), // Index 0
              ),
              title: Text(
                'Bitcoin',
                style: _buildTextStyle(0), // Index 0
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.credit_card,
                color: _buildIconColor(1), // Index 1
              ),
              title: Text(
                'Buy/Sell',
                style: _buildTextStyle(1), // Index 1
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.more_horiz,
                color: _buildIconColor(2), // Index 2
              ),
              title: Text(
                'More',
                style: _buildTextStyle(2), // Index 2
              ),
            )
          ]),
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: children[_currentIndex],
      ),
    );
  }
}
