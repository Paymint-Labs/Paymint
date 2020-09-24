import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';

class MoreView extends StatefulWidget {
  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff121212),
        body: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Settings',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Text(
                'General',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/generalview');
              },
            ),
            ListTile(
              leading: Text(
                'Advanced',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/advancedview');
              },
            ),
            ListTile(
              leading: Text(
                'Backup wallet',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                final wallet = await Hive.openBox('wallet');
                final bool useBiometrics = await wallet.get('use_biometrics');
                final LocalAuthentication localAuth = LocalAuthentication();

                bool canCheckBiometrics = await localAuth.canCheckBiometrics;

                // If useBiometrics is enabled, then show fingerprint auth screen
                if (useBiometrics && canCheckBiometrics) {
                  List<BiometricType> availableSystems = await localAuth.getAvailableBiometrics();

                  if (Platform.isIOS) {
                    if (availableSystems.contains(BiometricType.face)) {
                      // Write iOS specific code when required
                    } else if (availableSystems.contains(BiometricType.fingerprint)) {
                      // Write iOS specific code when required
                    }
                  } else if (Platform.isAndroid) {
                    if (availableSystems.contains(BiometricType.fingerprint)) {
                      bool didAuthenticate = await localAuth.authenticateWithBiometrics(
                        localizedReason: 'Please authenticate to view secret words',
                      );

                      if (didAuthenticate) Navigator.pushNamed(context, '/backupview');
                    }
                  }
                } else {
                  Navigator.pushNamed(context, '/backupview');
                }
              },
            ),
            ListTile(
              leading: Text(
                'Terms of Service',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _launchToS(context),
            ),
            ListTile(
              leading: Text(
                'Privacy Policy',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _launchPrivacyPolicy(context),
            ),
            ListTile(
              leading: Text(
                'About Paymint',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.info),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Paymint',
                  applicationIcon: Image.asset('assets/icon/icon.png', height: 40, width: 40),
                  applicationLegalese: 'All rights reserved © Ready Systems Ltd.\n\nPaymint Labs',
                  applicationVersion: '1.2.0',
                );
              },
            ),
            Expanded(
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}

void _launchTwitter(BuildContext context) async {
  final String url = 'https://twitter.com/paymint_labs';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}

void _launchToS(BuildContext context) async {
  final String url = 'https://paymint-tos.webflow.io/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}

void _launchPrivacyPolicy(BuildContext context) async {
  final String url = 'https://paymint-privacy-policy.webflow.io/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
