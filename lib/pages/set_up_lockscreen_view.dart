import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SetUpLockscreenView extends StatefulWidget {
  @override
  _SetUpLockscreenViewState createState() => _SetUpLockscreenViewState();
}

class _SetUpLockscreenViewState extends State<SetUpLockscreenView> {
  PageController _pageController = PageController(initialPage: 0, keepPage: true);
  GlobalKey<ScaffoldState> _globalKey1 = GlobalKey<ScaffoldState>();
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.cyanAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  // Attributes for Page 1 of the pageview
  final TextEditingController _pinPutController1 = TextEditingController();
  final FocusNode _pinPutFocusNode1 = FocusNode();

  // Attributes for Page 2 of the pageview
  final TextEditingController _pinPutController2 = TextEditingController();
  final FocusNode _pinPutFocusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _globalKey1,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            // Page 1

            Scaffold(
              bottomNavigationBar: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  'By using the app, you agree to the Terms of Service and Privacy Policy',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
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
                  Text('Please choose a PIN code to secure your wallet', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: PinPut(
                      autofocus: true,
                      textStyle: TextStyle(color: Colors.white),
                      fieldsCount: 4,
                      onSubmit: (String pin) {
                        _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.bounceIn);
                        FocusScope.of(context).unfocus();
                      },
                      focusNode: _pinPutFocusNode1,
                      controller: _pinPutController1,
                      submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20.0)),
                      selectedFieldDecoration: _pinPutDecoration,
                      followingFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.cyan, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),

            // Page 2

            Scaffold(
              bottomNavigationBar: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  'By using the app, you agree to the Terms of Service and Privacy Policy',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
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
                  Text('Please confirm the chosen PIN', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: PinPut(
                      autofocus: false,
                      textStyle: TextStyle(color: Colors.white),
                      fieldsCount: 4,
                      onSubmit: (String pin) async {
                        if (_pinPutController1.text == _pinPutController2.text) {
                          FocusScope.of(context).unfocus();

                          final store = new FlutterSecureStorage();
                          await store.write(key: 'pin', value: pin);
                          final misc = await Hive.openBox('miscellaneous_v2');
                          await misc.put('pin_set', true);
                          _globalKey1.currentState.hideCurrentSnackBar();
                          _globalKey1.currentState.showSnackBar(
                            SnackBar(
                                content: Text(
                                  'PIN code successfully set. Unlocking wallet...',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green),
                          );

                          await Future.delayed(Duration(milliseconds: 700));

                          Navigator.pushNamed(context, '/mainview');
                        } else {
                          FocusScope.of(context).unfocus();
                          _pageController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.bounceIn);
                          _globalKey1.currentState.hideCurrentSnackBar();
                          _globalKey1.currentState.showSnackBar(
                            SnackBar(
                              content:
                                  Text('PIN codes do not match. Try again.', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ),
                          );
                          _pinPutController1.text = '';
                          _pinPutController2.text = '';
                        }
                      },
                      focusNode: _pinPutFocusNode2,
                      controller: _pinPutController2,
                      submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20.0)),
                      selectedFieldDecoration: _pinPutDecoration,
                      followingFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
