import 'package:flutter/material.dart';
import 'package:paymint/services/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:animations/animations.dart';

class MoreView extends StatefulWidget {
  MoreView({Key key}) : super(key: key);

  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.black);
    final BitcoinService btcService = Provider.of<BitcoinService>(context);

    return FutureBuilder(
      future: btcService.currency,
      builder: (BuildContext context, AsyncSnapshot<String> currency) {
        if (currency.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: btcService.currentReceivingAddress,
            builder:
                (BuildContext context, AsyncSnapshot<String> currentAddress) {
              if (currentAddress.connectionState == ConnectionState.done) {
                return _buildMoreView(context, currency, currentAddress);
              } else {
                return _MoreViewLoading();
              }
            },
          );
        } else {
          return _MoreViewLoading();
        }
      },
    );
  }

  _buildMoreView(BuildContext context, AsyncSnapshot<String> currency,
      AsyncSnapshot<String> currentAddress) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(color: Colors.black, height: 250),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.rounded_corner),
                SizedBox(width: 10),
                Text('Advanced', textScaleFactor: 1.3),
              ],
            ),
          ),
          ListTile(
            title: Text('Refresh wallet data'),
            trailing: Icon(Icons.refresh, color: Colors.blue),
            onTap: () {},
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.language),
                SizedBox(width: 10),
                Text('Localization preferences', textScaleFactor: 1.3),
              ],
            ),
          ),
          ListTile(
            title: Text('Currency'),
            trailing: Text(currency.data, style: TextStyle(color: Colors.blue)),
            onTap: () {
              Navigator.pushNamed(context, '/changecurency'); 
            },
          ),
          ListTile(
            title: Text('Language'),
            trailing: Text('English', style: TextStyle(color: Colors.blue)),
            onTap: () {},
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.security),
                SizedBox(width: 10),
                Text('Security Options', textScaleFactor: 1.3),
              ],
            ),
          ),
          ListTile(
            title: Text('Manage backups'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: Text('Reset pattern lock'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.info),
                SizedBox(width: 10),
                Text('Legal', textScaleFactor: 1.3),
              ],
            ),
          ),
          ListTile(
            title: Text('Terms of service'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: Text('Licenses'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          )
        ],
      ),
    );
  }
}

class _MoreViewLoading extends StatelessWidget {
  const _MoreViewLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
