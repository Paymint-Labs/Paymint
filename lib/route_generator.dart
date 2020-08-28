import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './pages/pages.dart';

class RouteGenerator {
  // This functions handles all top level routes in the app. Subrouting is handled individually
  // inside relevant widgets
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed into Navigator.pushNamed
    // final args = settings.arguments;

    switch (settings.name) {
      case '/mainview':
        return CupertinoPageRoute(builder: (_) => MainView());
      case '/receive':
        return CupertinoPageRoute(builder: (_) => ReceiveView());
      case '/send':
        return CupertinoPageRoute(builder: (_) => SendView());
      case '/addressbook':
        return CupertinoPageRoute(builder: (_) => AddressBookView());
      case '/generalview':
        return CupertinoPageRoute(builder: (_) => GeneralView());
      case '/advancedview':
        return CupertinoPageRoute(builder: (_) => AdvancedView());
      case '/restorewalletview':
        return CupertinoPageRoute(builder: (_) => RestoreWalletView());
      case '/changecurrency':
        return CupertinoPageRoute(builder: (_) => ChangeCurrencyView());
      case '/esploraview':
        return CupertinoPageRoute(builder: (_) => EsploraView());
      default:
        return _routeError();
    }
  }
}

Route createSlideTransitionRoute(Widget viewToInsert) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => viewToInsert,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route<dynamic> _routeError() {
  // Replace with robust ErrorView page
  Widget errorView = Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text('Navigation error'),
    ),
    body: Center(
      child: Text('Error handling route, this is not supposed to happen. Try restarting the app.'),
    ),
  );

  return CupertinoPageRoute(builder: (_) => errorView);
}
