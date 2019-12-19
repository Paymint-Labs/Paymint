import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialAppWithTheme();
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paymint beta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitView(),
    );
  }
}

class InitView extends StatelessWidget {
  const InitView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}
