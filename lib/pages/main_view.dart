import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paymint/pages/pages.dart';

class MainView extends StatefulWidget {
  MainView({Key key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Color _buildIconColor(int index) {
    if (index == this._currentIndex) {
      return Colors.black;
    } else {
      return Colors.grey;
    }
  }

  TextStyle _buildTextStyle(int index) {
    if (index == this._currentIndex) {
      return GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black));
    } else {
      return GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
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
                'Buy',
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
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          BitcoinView(),
          Center(
            child: Text('Buy'),
          ),
          Center(
            child: Text('More'),
          ),
        ],
      ),
    );
  }
}
