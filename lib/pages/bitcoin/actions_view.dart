import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paymint/models/models.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:paymint/services/services.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:paymint/components/globals.dart';
import 'dart:math' as math;
import 'package:majascan/majascan.dart';
import 'package:animations/animations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ActionsView extends StatefulWidget {
  ActionsView({Key key}) : super(key: key);

  @override
  _ActionsViewState createState() => _ActionsViewState();
}

class _ActionsViewState extends State<ActionsView>
    with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    this._controller = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: TabBar(
          controller: _controller,
          labelStyle: GoogleFonts.rubik(),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(width: 3.0, color: Colors.blue),
          ),
          tabs: <Widget>[
            Tab(
              text: 'Receive',
            ),
            Tab(
              text: 'Send',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          _ReceiveView(),
          _SendView(),
        ],
      ),
    );
  }
}

class _ReceiveView extends StatefulWidget {
  _ReceiveView({Key key}) : super(key: key);

  @override
  __ReceiveViewState createState() => __ReceiveViewState();
}

class __ReceiveViewState extends State<_ReceiveView> {
  @override
  Widget build(BuildContext context) {
    final _bitcoinService = Provider.of<BitcoinService>(context);

    return Scaffold(
        bottomNavigationBar: Container(
          height: 125,
          child: ListView(
            children: <Widget>[
              ListTile(
                onTap: () {},
                title: Text('Reveal address text'),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {},
                title: Text('Show previous addresses'),
                trailing: Icon(Icons.chevron_right),
              )
            ],
          ),
        ),
        body: FutureBuilder(
          future: _bitcoinService.currentReceivingAddress,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data);
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(height: 50),
                    PrettyQr(
                      data: snapshot.data,
                      roundEdges: true,
                      elementColor: Colors.black,
                      typeNumber: 4,
                      size: 200,
                    ),
                    Container(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: snapshot.data));
                            Toast.show('Address copied to clipboard', context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          },
                          fillColor: Colors.black,
                          elevation: 0,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(15),
                          child: Icon(Icons.content_copy,
                              color: Colors.white, size: 20),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Share.share(snapshot.data);
                          },
                          fillColor: Colors.black,
                          elevation: 0,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(15),
                          child:
                              Icon(Icons.share, color: Colors.white, size: 20),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Toast.show('Feature coming soon', context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          },
                          fillColor: Colors.grey,
                          elevation: 0,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(15),
                          child: Icon(Icons.save_alt,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

class _SendView extends StatefulWidget {
  _SendView({Key key}) : super(key: key);

  @override
  __SendViewState createState() => __SendViewState();
}

class __SendViewState extends State<_SendView> {
  TextEditingController _btcAmountInput =
      new TextEditingController(text: '0.0' ?? '0');
  TextEditingController _recipientAddressInput = new TextEditingController();
  final RoundedLoadingButtonController _buttonController =
      new RoundedLoadingButtonController();

  String _btcAmountInFiat = '0.0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _doSomething() async {
    await Future.delayed(Duration(milliseconds: 3000));
    _buttonController.success();
    await Future.delayed(Duration(milliseconds: 2000));
    _buttonController.reset();
  }

  void updatePrice(double currentPrice) {
    setState(() {
      var newData = currentPrice * double.parse(_btcAmountInput.text);
      this._btcAmountInFiat = newData.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final btcService = Provider.of<BitcoinService>(context);
    final List<UtxoObject> _allOutputs = btcService.allOutputs;

    return FutureBuilder(
      future: btcService.currency,
      builder: (BuildContext context, AsyncSnapshot _currencyData) {
        if (_currencyData.connectionState == ConnectionState.done) {
          return FutureBuilder(
              future: btcService.bitcoinPrice,
              builder: (BuildContext context, AsyncSnapshot _bitcoinPrice) {
                if (_bitcoinPrice.connectionState == ConnectionState.done) {
                  final String displayBtcPrice = _bitcoinPrice.data.toString();
                  final String userCurrency = _currencyData.data;
                  final String currencySymbol = currencyMap[userCurrency];

                  return Scaffold(
                    bottomNavigationBar: Container(
                      height: 100,
                      child: Center(
                        child: RoundedLoadingButton(
                          child: Text('Authenticate transaction',
                              style: TextStyle(color: Colors.white)),
                          controller: _buttonController,
                          onPressed: _doSomething,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    controller: _btcAmountInput,
                                    style: TextStyle(fontSize: 20),
                                    decoration: InputDecoration(filled: true),
                                    onChanged: (amount) {
                                      updatePrice(_bitcoinPrice.data);
                                    },
                                    inputFormatters: [
                                      DecimalTextInputFormatter(decimalRange: 8)
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('BTC', textScaleFactor: 1.5),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                '~ Sending $currencySymbol$_btcAmountInFiat \n~ @ $currencySymbol$displayBtcPrice per Bitcoin',
                                textScaleFactor: 1.2,
                                style: TextStyle(
                                  color: Colors.grey,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Text("Recipient's address:",
                                textScaleFactor: 1.3),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    controller: _recipientAddressInput,
                                    style: TextStyle(fontSize: 20),
                                    decoration: InputDecoration(filled: true, helperText: 'Remember to delete any spaces'),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.camera_alt),
                                    onPressed: () async {
                                      String qrString =
                                          await MajaScan.startScan(
                                              title: 'Scan QR Code',
                                              titleColor: Colors.white,
                                              qRCornerColor: Colors.white,
                                              qRScannerColor: Colors.red,
                                              scanAreaScale: 0.7);
                                      this._recipientAddressInput.text =
                                          qrString;
                                    })
                              ],
                            ),
                          ),
                          // Center(
                          //     child: CupertinoButton.filled(
                          //         child: Text('Authenticate transaction'),
                          //         onPressed: () {
                          //           if (this._btcAmountInput.text == '0' ||
                          //               this._btcAmountInput.text == '0.0' ||
                          //               this._btcAmountInput.text == '0.00') {
                          //             showModal<void>(
                          //               context: context,
                          //               configuration:
                          //                   FadeScaleTransitionConfiguration(),
                          //               builder: (BuildContext context) {
                          //                 return _ZeroInputDialog();
                          //               },
                          //             );
                          //           } else if (double.parse(
                          //                   this._btcAmountInput.text) >=
                          //               returnMaxSpendableBitcoin(
                          //                   _allOutputs)) {
                          //             showModal<void>(
                          //               context: context,
                          //               configuration:
                          //                   FadeScaleTransitionConfiguration(),
                          //               builder: (BuildContext context) {
                          //                 return _InputAmountToMuchDialog();
                          //               },
                          //             );
                          //           } else {
                          //             Navigator.popAndPushNamed(
                          //                 context, 'pushtx');
                          //           }
                          //         }))
                        ],
                      ),
                    ),
                  );
                } else {
                  return _SendViewLoading();
                }
              });
        } else {
          return _SendViewLoading();
        }
      },
    );
  }
}

class _SendViewLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('Loading send view...')),
    );
  }
}

double returnMaxSpendableBitcoin(List<UtxoObject> allOutputs) {
  int totalSatoshiAmt = 0;
  for (var i = 0; i < allOutputs.length; i++) {
    if (allOutputs[i].blocked == false &&
        allOutputs[i].status.confirmed == true) {
      totalSatoshiAmt = totalSatoshiAmt + allOutputs[i].value;
    }
  }
  return totalSatoshiAmt / 100000000;
}

double _bitcoinToSatoshis(double btcAmount) {
  return btcAmount * 100000000;
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

class _InputAmountToMuchDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Amount too high'),
      content: Text(
          "You either don't have that much Bitcoin or you're not leaving enough in your wallet to pay for the fees for this transaction.\n\nPlease edit amount before continuing."),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _ZeroInputDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Amount too low'),
      content: Text("You need to send an amount greater than 0.0 BTC"),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
