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
import 'package:shimmer/shimmer.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

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
          height: 70,
          child: ListView(
            children: <Widget>[
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
  TextEditingController _inputAmount = TextEditingController(text: '0.0');
  TextEditingController _recipientAddress = TextEditingController();
  var rawFiatPrice = '0.0' ?? '0.0';

  recalculateDisplayPriceFromInput(amount, rawPriceInFiat) {
    final rawFiatPriceFromInput = rawPriceInFiat * double.parse(amount);
    final fmf = FlutterMoneyFormatter(amount: rawFiatPriceFromInput);
    rawFiatPrice = fmf.output.nonSymbol.toString();
    print(rawFiatPrice);
  }

  @override
  Widget build(BuildContext context) {
    final btcService = Provider.of<BitcoinService>(context);

    return FutureBuilder(
      future: btcService.currency,
      builder: (BuildContext context, AsyncSnapshot<String> userCurrency) {
        if (userCurrency.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: btcService.fees,
            builder:
                (BuildContext context, AsyncSnapshot<FeeObject> feeObject) {
              if (feeObject.connectionState == ConnectionState.done) {
                return FutureBuilder(
                  future: btcService.bitcoinPrice,
                  builder: (BuildContext context,
                      AsyncSnapshot<double> bitcoinPrice) {
                    if (bitcoinPrice.connectionState == ConnectionState.done) {
                      return _buildMainSendView(
                          context, feeObject, userCurrency, bitcoinPrice);
                    } else {
                      return _SendViewLoading();
                    }
                  },
                );
              } else {
                return _SendViewLoading();
              }
            },
          );
        } else {
          return _SendViewLoading();
        }
      },
    );
  }

  _buildMainSendView(BuildContext context, AsyncSnapshot<FeeObject> feeObj,
      AsyncSnapshot<String> currency, AsyncSnapshot<double> bitcoinPrice) {
    final String _currency = currency.data;
    final FeeObject _feeObj = feeObj.data;
    final BitcoinService btcService = Provider.of<BitcoinService>(context);
    final double rawBitcoinPrice = bitcoinPrice.data;

    var displayCurrency = currencyMap[_currency];
    var displayBitcoinPrice = FlutterMoneyFormatter(amount: rawBitcoinPrice)
        .output
        .nonSymbol
        .toString();

    return Scaffold(
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: RoundedLoadingButton(
              child: Text('Send transaction',
                  style: TextStyle(color: Colors.white)),
              controller: buttonController,
              onPressed: () {},
              color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Amount in bitcoin:'),
              // Bitcoin amount input text field
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _inputAmount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 20),
                      inputFormatters: [
                        DecimalTextInputFormatter(decimalRange: 8)
                      ],
                      onChanged: (amt) {
                        setState(() {
                          recalculateDisplayPriceFromInput(
                              amt, rawBitcoinPrice);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('BTC', textScaleFactor: 1.5)
                ],
              ),
              SizedBox(height: 32),
              Text('~ Sending $displayCurrency$rawFiatPrice in Bitcoin',
                  textScaleFactor: 1.3, style: TextStyle(color: Colors.grey)),
              Text('~ @ $displayCurrency$displayBitcoinPrice per Bitcoin',
                  textScaleFactor: 1.3, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 32),
              Text('Recipient\'s Address:'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(controller: _recipientAddress),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera),
                    onPressed: () async {
                      String qrString = await MajaScan.startScan(
                          title: 'Scan QR Code',
                          titleColor: Colors.white,
                          qRCornerColor: Colors.white,
                          qRScannerColor: Colors.red,
                          scanAreaScale: 0.7);
                      this._recipientAddress.text = qrString;
                    },
                  ),
                ],
              ),
              SizedBox(height: 60),
              Text('Fee selection:')

            ],
          ),
        ),
      ),
    );
  }
}

class _SendViewLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: CircularProgressIndicator()),
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

class _PushTxDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Please do not exit...'),
        content: Container(
            child: Center(child: CircularProgressIndicator()), height: 100));
  }
}
