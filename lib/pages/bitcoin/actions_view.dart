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
import 'package:hive/hive.dart';

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

  double selectedFee = 1.0;

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

  void _checkAndBuild() async {
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
    } else if (double.parse(_inputAmount.text) > (spendableSatoshiAmt / 100000000)) {
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
      print('Invalid address');
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _InvalidAddressDialog();
        },
      );
    }
  }

  Future<dynamic> _checkTransactionEligibilityAndBuild(BuildContext context,
      int satoshiAmountToSend, double selectedTxFee) async {
    final BitcoinService btcService = Provider.of<BitcoinService>(context);
    final List<UtxoObject> availableOutputs = btcService.allOutputs;
    final List<UtxoObject> spendableOutputs = new List();
    int spendableSatoshiValue = 0;

    // Build list of spendable outputs and totaling their satoshi amount
    for (var i = 0; i < availableOutputs.length; i++) {
      if (availableOutputs[i].blocked == false &&
          availableOutputs[i].status.confirmed == true) {
        spendableOutputs.add(availableOutputs[i]);
        spendableSatoshiValue += availableOutputs[i].value;
      }
    }

    // If the amount the user is trying to send is smaller than the amount that they have spendable,
    // then return 1, which indicates that they have an insufficient balance.
    if (spendableSatoshiValue < satoshiAmountToSend) {
      return 1;
      // If the amount the user wants to send is exactly equal to the amount they can spend, then return
      // 2, which indicates that they are not leaving enough over to pay the transaction fee
    } else if (spendableSatoshiValue == satoshiAmountToSend) {
      return 2;
    }
    // If neither of these statements pass, we assume that the user has a spendable balance greater
    // than the amount they're attempting to send. Note that this value still does not account for
    // the added transaction fee, which may require an extra input and will need to be checked for
    // later on.

    int satoshisBeingUsed = 0;
    int inputsBeingConsumed = 0;
    List<UtxoObject> utxoObjectsToUse = new List();

    while (satoshisBeingUsed < satoshiAmountToSend) {
      for (var i = 0; i < spendableOutputs.length; i++) {
        utxoObjectsToUse.add(spendableOutputs[i]);
        inputsBeingConsumed += spendableOutputs[i].value;
        inputsBeingConsumed += 1;
      }
    }

    // numberOfOutputs' length must always be equal to that of recipientsArray and recipientsAmtArray
    int numberOfOutputs = 1;
    List<String> recipientsArray = [_recipientAddress.text];
    List<int> recipientsAmtArray = [satoshiAmountToSend];

    // Assume 1 output, only for recipient and no change
    final feeForOneOutput =
        ((42 + 272 * inputsBeingConsumed + 128) / 4).ceil() *
            selectedTxFee.ceil();
    // Assume 2 outputs, one for recipient and one for change
    final feeForTwoOutputs =
        ((42 + 272 * inputsBeingConsumed + 128 * 2) / 4).ceil() *
            selectedTxFee.ceil();

    if (satoshisBeingUsed - satoshiAmountToSend > feeForOneOutput) {
      if (satoshisBeingUsed - satoshiAmountToSend > feeForOneOutput + 293) {
        // Here, we know that theoretically, we may be able to include another output(change) but we first need to
        // factor in the value of this output in satoshis
        int changeOutputSize =
            satoshisBeingUsed - satoshiAmountToSend - feeForTwoOutputs;
        if (changeOutputSize > 293 &&
            satoshisBeingUsed - satoshiAmountToSend - changeOutputSize ==
                feeForTwoOutputs) {
          await btcService.incrementAddressIndexForChain(1);
          final wallet = await Hive.openBox('wallet');
          final int changeIndex = await wallet.get('changeIndex');
          final String newChangeAddress =
              await btcService.generateAddressForChain(1, changeIndex);
          await btcService.addToAddressesArrayForChain(newChangeAddress, 1);
          recipientsArray.add(newChangeAddress);
          recipientsAmtArray.add(changeOutputSize);
          numberOfOutputs += 1;

          // At this point, we have the outputs we're going to use, the amounts to send along with which addresses
          // we intend to send these amounts to. We have enough to send instructions to build the transaction.

          final String hex = await btcService.buildTransaction(
              utxoObjectsToUse, recipientsArray, recipientsAmtArray);
        } else {
          // Something went wrong here. It either overshot or undershot the estimated fee amount or the changeOutputSize
          // is smaller than or equal to 293. Revert to single output transaction.
        }
      } else {
        // No additional outputs needed since adding one would mean that it'd be smaller than 293 sats
        // which makes it uneconomical to add to the transaction. Here, we pass data directly to instruct
        // the wallet to begin crafting the transaction that the user requested.
      }
    } else if (satoshisBeingUsed - satoshiAmountToSend == feeForOneOutput) {
      // In this scenario, no additional change output is needed since inputs - outputs equal exactly
      // what we need to pay for fees. Here, we pass data directly to instruct the wallet to begin
      // crafting the transaction that the user requested.
    } else {
      // Remember that returning 2 indicates that the user does not have a sufficient balance to
      // pay for the transaction fee. Ideally, at this stage, we should check if the user has any
      // additional outputs they're able to spend and then recalculate fees.
      return 2;
    }
  }

  _buildMainSendView(BuildContext context, AsyncSnapshot<FeeObject> feeObj,
      AsyncSnapshot<String> currency, AsyncSnapshot<double> bitcoinPrice) {
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
            _checkAndBuild();
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
          "You do not have that much Bitcoin to spend. Please try a smaller amount."),
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

class _NoInputDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('No amount selected'),
      content: Text(
          "The BTC amount input field is empty. Please enter a valid amount and retry."),
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

class _WaitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Please do not exit...'),
        content: Container(
            child: Center(child: CircularProgressIndicator()), height: 100));
  }
}
