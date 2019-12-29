import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './pages/pages.dart';

class RouteGenerator {
  // This functions handles all top level routes in the app. Subrouting is handled individually
  // inside relevant widgets
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed into Navigator.pushNamed
    // final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(builder: (_) => MainView());
      case '/onboard':
        return CupertinoPageRoute(builder: (_) => OnboardView());
      case '/actions':
        return CupertinoPageRoute(builder: (_) => ActionsView());
      default:
        return _routeError();
    }
  }
}

Route<dynamic> _routeError() {
  Widget errorView = Scaffold(
    body: Center(
      child: Text('Error handling route', style: GoogleFonts.rubik()),
    ),
  );

  return CupertinoPageRoute(builder: (_) => errorView);
}