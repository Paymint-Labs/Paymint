import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './pages.dart';
import 'package:flutter/services.dart';

/// MainView refers to the main tab bar navigation and view system in place
class MainView extends StatefulWidget {
  MainView({Key key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  List<Widget> children = [
    WalletView(),
    InvestView(),
    TransactionsView(),
    TransferView(),
    MoreView(),
  ];

  /// Tab icon color based on tab selection
  Color _buildIconColor(int index) {
    if (index == this._currentIndex) {
      return Color(0xff81D4FA);
    } else {
      return Colors.grey;
    }
  }

  /// Tab text color based on tab selection
  TextStyle _buildTextStyle(int index) {
    if (index == this._currentIndex) {
      return GoogleFonts.rubik(textStyle: TextStyle(color: Color(0xff81D4FA)));
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
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xff121212),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        key: _key,
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(canvasColor: Color(0xff121212)),
          child: BottomNavigationBar(
            elevation: 0,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.shifting,
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
                  'Wallet',
                  style: _buildTextStyle(0), // Index 0
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.attach_money,
                  color: _buildIconColor(1),
                ),
                title: Text(
                  'Invest',
                  style: _buildTextStyle(1), // Index 0
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.menu,
                  color: _buildIconColor(2), // Index 1
                ),
                title: Text(
                  'Transactions',
                  style: _buildTextStyle(2), // Index 1
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.send,
                  color: _buildIconColor(3), // Index 2
                ),
                title: Text(
                  'Transfer',
                  style: _buildTextStyle(3), // Index 2
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  color: _buildIconColor(4), // Index 2
                ),
                title: Text(
                  'Settings',
                  style: _buildTextStyle(4), // Index 2
                ),
              )
            ],
          ),
        ),
        body: IndexedStack(
          children: children,
          index: _currentIndex,
        ),
      ),
    );
  }
}
