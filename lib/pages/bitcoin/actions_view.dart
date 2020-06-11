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

  dynamic selectedFee;

  recalculateDisplayPriceFromInput(amount, rawPriceInFiat) {
    final rawFiatPriceFromInput = rawPriceInFiat * double.parse(amount);
    final fmf = FlutterMoneyFormatter(amount: rawFiatPriceFromInput);
    rawFiatPrice = fmf.output.nonSymbol.toString();
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
                      AsyncSnapshot<dynamic> bitcoinPrice) {
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

  void _checkAndBuild(FeeObject _feeObject) async {
    final BitcoinService btcService = Provider.of<BitcoinService>(context);
    final List<UtxoObject> allOutputs = btcService.allOutputs;
    int spendableSatoshiAmt = 0;

    for (var i = 0; i < allOutputs.length; i++) {
      if (allOutputs[i].blocked == false &&
          allOutputs[i].status.confirmed == true) {
        spendableSatoshiAmt += allOutputs[i].value;
      }
    }

    var checkAddress = (String address) {
      return address.startsWith('1') ||
          address.startsWith('3') ||
          address.startsWith('bc1');
    };

    // Show initial loading dialog
    showModal(
      context: context,
      configuration:
          FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (BuildContext context) {
        return _WaitDialog();
      },
    );

    // Hard checks for inputAmount
    // If input == 0, then show ZeroInputDialog
    if (double.parse(_inputAmount.text ??= '0.0') == 0.0) {
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _ZeroInputDialog();
        },
      );
    } else if (double.parse(_inputAmount.text) >
        (spendableSatoshiAmt / 100000000)) {
      print(_inputAmount.text);
      print(spendableSatoshiAmt / 100000000);
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _InputAmountToMuchDialog();
        },
      );
    }

    // Check recipient address
    if (checkAddress(_recipientAddress.text) == false) {
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _InvalidAddressDialog();
        },
      );
    }

    // If none of the above cases get triggered, attempt to build transaction
    int satoshiAmount = (double.parse(_inputAmount.text) * 100000000).toInt();
    print(satoshiAmount);
    print(spendableSatoshiAmt);
    dynamic transactionHexOrError = await btcService.coinSelection(
      satoshiAmount,
      _feeObject.fast,
      _recipientAddress.text,
    );

    if (transactionHexOrError is int) {
      // transactionHexOrError == 1 indicates an insufficient balance whereas 2 would indicate
      // an adequate balance but an inability to pay for tx fees with leftover balance, same ui for both for now
      if (transactionHexOrError == 1 || transactionHexOrError == 2) {
        Navigator.pop(context);
        showModal(
          context: context,
          configuration: FadeScaleTransitionConfiguration(),
          builder: (BuildContext context) {
            return _InputAmountToMuchDialog();
          },
        );
      }
    } else {
      // In this case, we receive a Map<String, dynamic> with keys: hex, recipient, recipientAmt, and fee
      // We show this in an alert dialog so that the user can approve their transaction before sending it
      Navigator.pop(context);
      print(transactionHexOrError);
      showModal(
          context: context,
          configuration: FadeScaleTransitionConfiguration(),
          builder: (BuildContext context) {
            return _PreviewTransactionDialog(
              transactionHexOrError['hex'],
              transactionHexOrError['recipient'],
              transactionHexOrError['recipientAmt'],
              transactionHexOrError['fee'],
            );
          });
    }
  }

  _buildMainSendView(BuildContext context, AsyncSnapshot<FeeObject> feeObj,
      AsyncSnapshot<String> currency, AsyncSnapshot<dynamic> bitcoinPrice) {
    final String _currency = currency.data;
    final FeeObject _feeObj = feeObj.data;
    final BitcoinService btcService = Provider.of<BitcoinService>(context);
    final double rawBitcoinPrice = bitcoinPrice.data;

    final String displayCurrency = currencyMap[_currency];
    final String displayBitcoinPrice =
        FlutterMoneyFormatter(amount: rawBitcoinPrice)
            .output
            .nonSymbol
            .toString();

    return Scaffold(
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
            child: CupertinoButton.filled(
          child: Text('Preview transaction'),
          onPressed: () async {
            _checkAndBuild(_feeObj);
          },
        )),
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
              SizedBox(height: 60)
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
          "You do not have that much Bitcoin to spend. Please try a smaller amount.\n\n It's also possible you're not leaving enough over for transaction fees."),
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
      content: Text("You need to send more than 0 BTC"),
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

class _InvalidAddressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Invalid address'),
      content: Text(
          "You're trying to send bitcoin to an invalid address. Please edit the recipient field and try again."),
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

class _PreviewTransactionDialog extends StatelessWidget {
  final String hex;
  final String recipient;
  final int recipientAmt;
  final int fees;

  String _displauAddr(String address) {
    return address.substring(0, 5) +
        '...' +
        address.substring(address.length - 5);
  }

  // Parameters optional for now
  _PreviewTransactionDialog(
      this.hex, this.recipient, this.recipientAmt, this.fees);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Scaffold(
          bottomNavigationBar: Container(
            height: 100,
            child: Center(
              child: CupertinoButton.filled(child: Text('Send Transaction'), onPressed: () {}),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 16),
                Center(
                    child: Text('Confirm transaction details',
                        textScaleFactor: 1.5)),
                SizedBox(height: 32),
                ListTile(
                  title: Text('Recipient:'),
                  trailing: Text(_displauAddr(recipient),
                      style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Amount (in BTC):'),
                  trailing: Text((recipientAmt / 100000000).toString(),
                      style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Fees (in sats):'),
                  trailing: Text(fees.toString(),
                      style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Copy transaction hex',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: hex));
                    Toast.show('Transaction hex copied to clipboard', context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  },
                ),
                ListTile(
                  title: Text('Save hex to local database',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: hex));
                    Toast.show('Transaction hex stored locally', context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Please do not exit...'),
        content: Container(
            child: Center(child: CircularProgressIndicator()), height: 100));
  }
}
