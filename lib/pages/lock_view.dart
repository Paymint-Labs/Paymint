import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class LockscreenView extends StatefulWidget {
  LockscreenView({Key key}) : super(key: key);

  @override
  _LockscreenViewState createState() => _LockscreenViewState();
}

class _LockscreenViewState extends State<LockscreenView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _checkUseBiometrics() async {
    final wallet = await Hive.openBox('wallet');
    final bool useBiometrics = await wallet.get('use_biometrics');
    final LocalAuthentication localAuth = LocalAuthentication();

    bool canCheckBiometrics = await localAuth.canCheckBiometrics;

    // If useBiometrics is enabled, then show fingerprint auth screen
    if (useBiometrics && canCheckBiometrics) {
      List<BiometricType> availableSystems =
          await localAuth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableSystems.contains(BiometricType.face)) {
          // Write iOS specific code when required
        } else if (availableSystems.contains(BiometricType.fingerprint)) {
          // Write iOS specific code when required
        }
      } else if (Platform.isAndroid) {
        if (availableSystems.contains(BiometricType.fingerprint)) {
          bool didAuthenticate = await localAuth.authenticateWithBiometrics(
            localizedReason: 'Please authenticate to access wallet',
            stickyAuth: true
          );

          if (didAuthenticate) { Navigator.pushNamed(context, '/mainview'); }
        }
      }
    }
  }

  @override
  void initState() {
    _checkUseBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Draw pattern to unlock',
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.3,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: PatternLock(
                  selectedColor: Colors.purple,
                  dimension: 3,
                  notSelectedColor: Colors.white,
                  onInputComplete: (List<int> input) async {
                    final store = new FlutterSecureStorage();
                    final String pattern = await store.read(key: 'lockcode');
                    final List patternListJson = jsonDecode(pattern);
                    List<int> actual = new List();
                    for (var i = 0; i < patternListJson.length; i++) {
                      actual.add(patternListJson[i]);
                    }
                    if (listEquals(actual, input)) {
                      Navigator.pushNamed(context, '/mainview');
                    } else {
                      scaffoldKey.currentState.hideCurrentSnackBar();
                      scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Incorrect pattern. Try again.')));
                    }
                  }),
            )
          ],
        ));
  }
}
