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
      case '/onboard':
        return CupertinoPageRoute(builder: (_) => OnboardView());
      case '/changecurency':
        return CupertinoPageRoute(builder: (_) => CurrencyChangeView());
      case '/backupmanager':
        return CupertinoPageRoute(builder: (_) => ManageBackupView());
      case '/revealmnemonic':
        return CupertinoPageRoute(builder: (_) => RevealMnemonicView());
      case '/restorewallet':
        return CupertinoPageRoute(builder: (_) => RestoreWalletView());
      case '/alladdresses':
        return CupertinoPageRoute(builder: (_) => AllAddressesView());
      case '/lockscreen':
        return CupertinoPageRoute(builder: (_) => LockscreenView());
      case '/404':
        return CupertinoPageRoute(builder: (_) => Error404View());
      default:
        return _routeError();
    }
  }
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