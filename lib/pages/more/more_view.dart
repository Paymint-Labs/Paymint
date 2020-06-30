import 'package:flutter/material.dart';
import 'package:paymint/services/services.dart';
import 'package:provider/provider.dart';
import 'package:paymint/components/globals.dart';
import 'package:animations/animations.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class MoreView extends StatefulWidget {
  MoreView({Key key}) : super(key: key);

  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  Widget build(BuildContext context) {
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
                return FutureBuilder(
                  future: btcService.useBiometrics,
                  builder: (BuildContext context, AsyncSnapshot<bool> bioAuth) {
                    if (bioAuth.connectionState == ConnectionState.done) {
                      return _buildMoreView(
                          context, currency, currentAddress, bioAuth);
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
        } else {
          return _MoreViewLoading();
        }
      },
    );
  }

  String _displayFormatAddress(String address) {
    return address.substring(0, 5) +
        '...' +
        address.substring(address.length - 5);
  }

  _buildMoreView(BuildContext context, AsyncSnapshot<String> currency,
      AsyncSnapshot<String> currentAddress, AsyncSnapshot<bool> useBiometrics) {
    return Scaffold(
      key: moreViewKey,
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black,
            height: 150,
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  color: Colors.white,
                  child: Text(_displayFormatAddress(currentAddress.data)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () {},
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        new ClipboardData(text: currentAddress.data));
                    Toast.show('Address copied to clipboard', context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  },
                  icon: Icon(Icons.content_copy),
                  color: Colors.white,
                ),
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.rounded_corner),
                SizedBox(width: 10),
                Text('General', textScaleFactor: 1.3),
              ],
            ),
          ),
          ListTile(
            title: Text('Refresh wallet'),
            trailing: Icon(Icons.refresh, color: Colors.blue),
            onTap: () async {
              final BitcoinService btcService =
                  Provider.of<BitcoinService>(context);
              showModal(
                context: context,
                configuration:
                    FadeScaleTransitionConfiguration(barrierDismissible: false),
                builder: (BuildContext context) {
                  return _refreshDialog();
                },
              );
              await btcService.refreshWalletData();
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Follow us on Twitter'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _launchTwitter(context);
            },
          ),
          ListTile(
            title: Text('Join us on Discord'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _launchDiscord(context);
            },
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
            onTap: () {
              Toast.show('More languages coming soon', context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            },
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
            onTap: () {
              Navigator.pushNamed(context, '/backupmanager');
            },
          ),
          ListTile(
            title: Text('Biometric authentication'),
            trailing: Text(_returnBioAuthDisplayText(useBiometrics.data),
                style: TextStyle(color: Colors.blue)),
            onTap: () async {
              final BitcoinService bitcoinService =
                  Provider.of<BitcoinService>(context);
              await bitcoinService.updateBiometricsUsage();
            },
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
            title: Text('Licenses'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                  context: context,
                  applicationName: 'Paymint',
                  applicationIcon: Image.asset('assets/icon/icon.png',
                      height: 40, width: 40),
                  applicationLegalese:
                      'All rights reserved © Ready Systems Ltd.\n\nPaymint Labs',
                  applicationVersion: '0.1.0');
            },
          ),
          ListTile(
            title: Text('Terms of service'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _launchToS(context);
            },
          ),
          ListTile(
            title: Text('Privacy policy'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _launchPrivacyPolicy(context);
            },
          ),
        ],
      ),
    );
  }

  String _returnBioAuthDisplayText(bool authSetting) {
    if (authSetting == true) {
      return 'Enabled';
    } else {
      return 'Disabled';
    }
  }

  _refreshDialog() {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Refreshing...')
        ],
      ),
    );
  }
}

void _launchTwitter(BuildContext context) async {
  final String url = 'https://twitter.com/paymint_labs';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}

void _launchToS(BuildContext context) async {
  final String url = 'https://paymint-tos.webflow.io/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}

void _launchPrivacyPolicy(BuildContext context) async {
  final String url = 'https://paymint-privacy-policy.webflow.io/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}

void _launchDiscord(BuildContext context) async {
  final String url = 'https://discord.gg/N8RNnev';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}

class _MoreViewLoading extends StatelessWidget {
  const _MoreViewLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: moreViewKey,
        body: ListView(
      children: <Widget>[
        Container(
          height: 150,
          color: Colors.black,
        ),
        Center(
          child: CircularProgressIndicator(),
        )
      ],
    ));
  }
}
