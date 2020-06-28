import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/bitcoin_service.dart';

class Error404View extends StatefulWidget {
  Error404View({Key key}) : super(key: key);

  @override
  _Error404ViewState createState() => _Error404ViewState();
}

class _Error404ViewState extends State<Error404View> {
  bool _connectionFound = false;
  
  @override
  void initState() {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        this._connectionFound = true;
        await bitcoinService.refreshWalletData();
        Navigator.pop(context);
      }
    });
    super.initState();
  }

  buildConnectionLoadingView() {
    if (this._connectionFound) {
      return Text('Connection found', style: TextStyle(color: Colors.green), textScaleFactor: 1.2);
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32,0,32,0),
        child: LinearProgressIndicator(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height / 1.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/404image.png',),
                  SizedBox(height: 16),
                  Text("Oops. Looks like you've been disconnected.", style: TextStyle(color: Colors.white), textAlign: TextAlign.center, textScaleFactor: 1.3,)
                ],
              )
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text("We'll redirect you back to the main app once we detect an active connection...", textScaleFactor: 1.2),
          ),
          SizedBox(height: 32),
          Center(child: buildConnectionLoadingView())
        ],
      ),
    );
  }
}
