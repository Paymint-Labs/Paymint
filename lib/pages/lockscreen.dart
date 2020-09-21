import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import 'package:hive/hive.dart';

class LockscreenView extends StatefulWidget {
  @override
  _LockscreenViewState createState() => _LockscreenViewState();
}

class _LockscreenViewState extends State<LockscreenView> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.cyanAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  // Attributes for Page 1 of the pageview
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  _checkUseBiometrics() async {
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
            localizedReason: 'Please authenticate to unlock wallet',
          );

          if (didAuthenticate) Navigator.pushNamed(context, '/mainview');
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
      key: _globalKey,
      backgroundColor: Color(0xff121212),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/splash.png',
              height: 75,
            ),
          ),
          SizedBox(height: 16),
          Text('Please input PIN to unlock wallet', style: TextStyle(color: Colors.white)),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: PinPut(
              autofocus: false,
              textStyle: TextStyle(color: Colors.white),
              fieldsCount: 4,
              onSubmit: (String pin) async {
                final store = new FlutterSecureStorage();

                final storedPin = await store.read(key: 'pin');

                if (storedPin == pin) {
                  FocusScope.of(context).unfocus();

                  _globalKey.currentState.hideCurrentSnackBar();
                  _globalKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'PIN code correct. Unlocking wallet...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                  await Future.delayed(Duration(milliseconds: 600));
                  Navigator.pushNamed(context, '/mainview');
                } else {
                  FocusScope.of(context).unfocus();

                  _globalKey.currentState.hideCurrentSnackBar();
                  _globalKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Incorrect PIN. Please try again',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                  _pinPutController.text = '';
                }
              },
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20.0)),
              selectedFieldDecoration: _pinPutDecoration,
              followingFieldDecoration: _pinPutDecoration.copyWith(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(width: 1.5, color: Colors.cyan),
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
