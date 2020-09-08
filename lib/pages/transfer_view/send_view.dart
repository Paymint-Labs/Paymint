import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:majascan/majascan.dart';
import 'package:paymint/models/models.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/globals.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:toast/toast.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SendView extends StatefulWidget {
  SendView({Key key}) : super(key: key);

  @override
  _SendViewState createState() => _SendViewState();
}

class _SendViewState extends State<SendView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Class attributes for recipient address
  String recipientAddress;
  TextEditingController recipientAddressTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Class atributes for recipient amount
  TextEditingController satsAmountController;
  TextEditingController btcAmountController;
  TextEditingController fiatAmountController;

  bool showFinalTxDetails = false;

  dynamic satoshiAmount = 0;
  dynamic btcAmount = 0.0;
  dynamic fiatAmount = 0.00;

  int currentDenominationSelection = 2; // Defaults to fiat

  int feeSelection = 0; // Defaults to fast
  String feeDescription = 'Fast >>>';

  FeeObject feeObjectRaw;

  @override
  void initState() {
    satsAmountController = TextEditingController(text: satoshiAmount.toString());
    btcAmountController = TextEditingController(text: btcAmount.toString());
    fiatAmountController = TextEditingController(text: fiatAmount.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xff121212),
        bottomNavigationBar: Container(
          height: 100,
          child: FutureBuilder(
            future: bitcoinService.fees,
            builder: (BuildContext context, AsyncSnapshot<FeeObject> fees) {
              if (fees.connectionState == ConnectionState.done) {
                return FutureBuilder(
                  future: bitcoinService.bitcoinPrice,
                  builder: (BuildContext context, AsyncSnapshot<dynamic> price) {
                    if (price.connectionState == ConnectionState.done) {
                      return FutureBuilder(
                        future: bitcoinService.currency,
                        builder: (BuildContext context, AsyncSnapshot<String> currency) {
                          if (currency.connectionState == ConnectionState.done) {
                            return buildPreviewButton(context, fees.data, price.data, currency.data);
                          } else {
                            return Container();
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'Send Bitcoin',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildAddRecipientContainer(),
            FutureBuilder(
              future: bitcoinService.currency,
              builder: (BuildContext context, AsyncSnapshot<String> currency) {
                if (currency.connectionState == ConnectionState.done) {
                  return _buildSelectAmountToSendContainer(currency.data);
                } else {
                  return Container();
                }
              },
            ),
            _buildFeeListTile()
          ],
        ),
      ),
    );
  }

  /// The container that allows user to supply data to [recipeintAddress]
  _buildAddRecipientContainer() {
    if (this.recipientAddress == null) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            child: Ink(
              decoration: BoxDecoration(color: Colors.amber),
              child: InkWell(
                onTap: () {
                  showModal(
                    context: context,
                    configuration: FadeScaleTransitionConfiguration(),
                    builder: (BuildContext context) {
                      return showChangeRecipientDialog();
                    },
                  );
                },
                child: Container(
                  height: 50,
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(
                        Icons.add,
                        size: 35,
                        color: Color(0xff121212),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Add recipient\'s address',
                        textScaleFactor: 1.1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return ListTile(
        title: Text(
          'Recipient:',
          style: TextStyle(color: Colors.white),
        ),
        trailing: formatAddress(this.recipientAddress),
        onTap: () {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(),
            builder: (BuildContext context) {
              return showChangeRecipientDialog();
            },
          );
        },
      );
    }
  }

  _buildSelectAmountToSendContainer(String currency) {
    if (recipientAddress == null) {
      return Container();
    } else {
      if (!showFinalTxDetails) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              child: Ink(
                decoration: BoxDecoration(color: Colors.amber),
                child: InkWell(
                  onTap: () => showSelectAmountToSendView(),
                  child: Container(
                    height: 50,
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Image.asset(
                          'assets/images/btc.png',
                          height: 35,
                          color: Color(0xff121212),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Select amount to send',
                          textScaleFactor: 1.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        // Return a receipt view of the proposed transaction amount here
        return ListTile(
          title: Text(
            'Amount:',
            style: TextStyle(color: Colors.white),
          ),
          trailing: buildSendAmountText(currency),
          onTap: () => showSelectAmountToSendView(),
        );
      }
    }
  }

  showChangeRecipientDialog() {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        'Enter recipient\'s address:',
        style: TextStyle(color: Colors.white),
      ),
      content: Container(
        height: 60,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: recipientAddressTextController,
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(),
            validator: (address) => validateAddress(address.trim()),
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Text('SCAN QR', style: TextStyle(color: Colors.cyanAccent)),
          onPressed: () async {
            String scan = await MajaScan.startScan(
              title: 'Scan QR Code',
              titleColor: Colors.white,
              qRCornerColor: Colors.cyanAccent,
              qRScannerColor: Colors.cyan,
            );

            recipientAddressTextController.text = scan.trim();
          },
        ),
        FlatButton(
          child: Text('CANCEL', style: TextStyle(color: Colors.cyanAccent)),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('OK', style: TextStyle(color: Colors.cyanAccent)),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              setState(() {
                recipientAddress = recipientAddressTextController.text.trim();
              });
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  showSelectAmountToSendView() {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return FutureBuilder(
              future: bitcoinService.bitcoinPrice,
              builder: (BuildContext context, AsyncSnapshot<dynamic> price) {
                if (price.connectionState == ConnectionState.done) {
                  if (price.hasError || price.data == null) {
                    return Container(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Couldn\'t fetch Bitcoin price.\nPlease check connection.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return FutureBuilder(
                    future: bitcoinService.currency,
                    builder: (BuildContext context, AsyncSnapshot<String> currency) {
                      if (currency.connectionState == ConnectionState.done) {
                        return Container(
                          // height: MediaQuery.of(context).size.height / 1.25,
                          color: Colors.black,
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  SizedBox(height: 12),

                                  /// Denomination selector row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () => changeDenominationSelection(0, setState),
                                        child: Text(
                                          'BTC',
                                          style: TextStyle(
                                            color: buildSelectionColor(0),
                                            fontWeight: buildSelectionWeight(0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () => changeDenominationSelection(1, setState),
                                        child: Text(
                                          'SATS',
                                          style: TextStyle(
                                            color: buildSelectionColor(1),
                                            fontWeight: buildSelectionWeight(1),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () => changeDenominationSelection(2, setState),
                                        child: Text(
                                          currency.data,
                                          style: TextStyle(
                                            color: buildSelectionColor(2),
                                            fontWeight: buildSelectionWeight(2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 100),

                                  /// Amount container
                                  Column(
                                    children: [
                                      Text(
                                        'I want to send',
                                        textScaleFactor: 1.5,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(height: 8),
                                      buildAmountInputBox(currency.data, price.data)
                                    ],
                                  ),

                                  SizedBox(height: 150),

                                  /// Confirm Button
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Material(
                                      child: Ink(
                                        decoration: BoxDecoration(color: Colors.amber),
                                        child: InkWell(
                                          child: Container(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            child: Center(
                                              child: Text(
                                                'Confirm amount',
                                                style: TextStyle(color: Color(0xff121212), fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            // Check to see that user isnt spending 0 sats, more sats than they have, or an amount equal to that they have spendable in the first place
                                            final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

                                            final List<UtxoObject> allOutputs = bitcoinService.allOutputs;
                                            int spendableSatoshiAmount = 0;

                                            for (var i = 0; i < allOutputs.length; i++) {
                                              if (allOutputs[i].blocked == false &&
                                                  allOutputs[i].status.confirmed == true) {
                                                spendableSatoshiAmount += allOutputs[i].value;
                                              }
                                            }

                                            final int satoshiAmountInt =
                                                double.parse(satsAmountController.text).toInt();

                                            if (satoshiAmountInt == 0) {
                                              this.setState(() {
                                                satsAmountController.text = '0';
                                                btcAmountController.text = '0.0';
                                                fiatAmountController.text = '0.00';
                                                showFinalTxDetails = false;
                                              });

                                              showModal(
                                                context: context,
                                                configuration: FadeScaleTransitionConfiguration(),
                                                builder: (BuildContext context) {
                                                  return zeroAmountDialog(context);
                                                },
                                              );
                                            } else if (satoshiAmountInt != 0 &&
                                                satoshiAmountInt > spendableSatoshiAmount) {
                                              this.setState(() {
                                                satsAmountController.text = '0';
                                                btcAmountController.text = '0.0';
                                                fiatAmountController.text = '0.00';
                                                showFinalTxDetails = false;
                                              });

                                              showModal(
                                                context: context,
                                                configuration: FadeScaleTransitionConfiguration(),
                                                builder: (BuildContext context) {
                                                  return tooMuchDialog(context);
                                                },
                                              );
                                            } else if (satoshiAmountInt != 0 &&
                                                satoshiAmountInt == spendableSatoshiAmount) {
                                              this.setState(() {
                                                satsAmountController.text = '0';
                                                btcAmountController.text = '0.0';
                                                fiatAmountController.text = '0.00';
                                                showFinalTxDetails = false;
                                              });

                                              showModal(
                                                context: context,
                                                configuration: FadeScaleTransitionConfiguration(),
                                                builder: (BuildContext context) {
                                                  return exactAmountDialog(context);
                                                },
                                              );
                                            } else {
                                              // In this case, we assume that the payment can go through. Not 100% certain though,
                                              // further checking done on another view.
                                              this.setState(() {
                                                this.showFinalTxDetails = true;
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12)
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return buildAmountViewLoading();
                      }
                    },
                  );
                } else {
                  return buildAmountViewLoading();
                }
              },
            );
          },
        );
      },
    );
  }

  // Functions for amount denomination row

  FontWeight buildSelectionWeight(int index) {
    if (index == currentDenominationSelection) {
      return FontWeight.bold;
    } else {
      return FontWeight.normal;
    }
  }

  Color buildSelectionColor(int index) {
    if (index == currentDenominationSelection) {
      return Colors.white;
    } else {
      return Colors.grey;
    }
  }

  void changeDenominationSelection(int index, StateSetter setState) {
    setState(() {
      currentDenominationSelection = index;
    });
  }

  // Functions for amount container

  Widget buildAmountInputBox(String currency, dynamic bitcoinPrice) {
    if (currentDenominationSelection == 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: btcAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [NumberRemoveExtraDotFormatter(decimalRange: 8)],
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(suffixText: 'BTC'),
              onChanged: (String btcAmount) {
                final btcAmountNum = double.parse(btcAmount);

                final satoshiAmount = ((btcAmountNum * 100000000).toInt());
                final fiatAmountString = (btcAmountNum * bitcoinPrice).toStringAsFixed(2);

                satsAmountController.text = satoshiAmount.toString();
                fiatAmountController.text = fiatAmountString;
              },
            ),
          ),
        ],
      );
    } else if (currentDenominationSelection == 1) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: satsAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(suffixText: 'SATS'),
              onChanged: (String satoshiAmount) {
                final satoshiAmountNum = double.parse(satoshiAmount).toInt();

                final btcAmountNum = satoshiAmountNum / 100000000;
                final fiatAmountString = (btcAmountNum * bitcoinPrice).toStringAsFixed(2);

                btcAmountController.text = btcAmountNum.toString();
                fiatAmountController.text = fiatAmountString;
              },
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: fiatAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [NumberRemoveExtraDotFormatter(decimalRange: 2)],
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(prefixText: currencyMap[currency] + ' '),
              onChanged: (String fiatAmount) {
                final fiatAmountNum = double.parse(fiatAmount);

                final btcAmount = (fiatAmountNum / bitcoinPrice).toStringAsFixed(8);
                final satoshiAmount = (double.parse(btcAmount) * 100000000).toInt();

                btcAmountController.text = btcAmount.toString();
                satsAmountController.text = satoshiAmount.toString();
              },
            ),
          ),
        ],
      );
    }
  }

  buildSendAmountText(String currency) {
    if (currentDenominationSelection == 0) {
      return Text(btcAmountController.text + ' BTC', style: TextStyle(color: Colors.cyanAccent));
    } else if (currentDenominationSelection == 1) {
      return Text(satsAmountController.text + ' SATS', style: TextStyle(color: Colors.cyanAccent));
    } else {
      return Text(
        currencyMap[currency] + fiatAmountController.text + ' worth of Bitcoin',
        style: TextStyle(color: Colors.cyanAccent),
      );
    }
  }

  _buildFeeListTile() {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return FutureBuilder(
      future: bitcoinService.fees,
      builder: (BuildContext context, AsyncSnapshot<FeeObject> feeObject) {
        if (feeObject.connectionState == ConnectionState.done) {
          if (feeObject == null || feeObject.hasError) {
            return ListTile(
              title: Text(
                'Could not fetch fee info.\nPlease check connection',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            );
          }

          return ListTile(
            title: Text('Fee selection:', style: TextStyle(color: Colors.white)),
            trailing: Text(feeDescription, style: TextStyle(color: Colors.cyanAccent)),
            onTap: () => showFeeSelectionModal(),
          );
        } else {
          return ListTile(title: Text('Fetching fee information...', style: TextStyle(color: Colors.white)));
        }
      },
    );
  }

  showFeeSelectionModal() async {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    buildColorForTiles(int index) {
      if (index == feeSelection) {
        return Colors.cyanAccent;
      } else {
        return Colors.white;
      }
    }

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder(
              future: bitcoinService.fees,
              builder: (BuildContext context, AsyncSnapshot<FeeObject> feeObj) {
                if (feeObj.connectionState == ConnectionState.done) {
                  return Material(
                    color: Colors.black,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Your selection here determines the speed of the transaction. The more you pay in fees, the faster it will be accepted by the receiving party.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 12),
                        ListTile(
                          title: Text(
                            feeObj.data.fast.toString() + ' sats/vByte',
                            style: TextStyle(color: buildColorForTiles(0)),
                          ),
                          trailing: Text('Fast >>>', style: TextStyle(color: buildColorForTiles(0))),
                          onTap: () {
                            setState(() {
                              feeSelection = 0;
                            });
                            this.setState(() {
                              feeDescription = 'Fast >>>';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(
                            feeObj.data.medium.toString() + ' sats/vByte',
                            style: TextStyle(color: buildColorForTiles(1)),
                          ),
                          trailing: Text('Medium >>', style: TextStyle(color: buildColorForTiles(1))),
                          onTap: () {
                            setState(() {
                              feeSelection = 1;
                            });
                            this.setState(() {
                              feeDescription = 'Medium >>';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(
                            feeObj.data.slow.toString() + ' sats/vByte',
                            style: TextStyle(color: buildColorForTiles(2)),
                          ),
                          trailing: Text('Slow >', style: TextStyle(color: buildColorForTiles(2))),
                          onTap: () {
                            setState(() {
                              feeSelection = 2;
                            });
                            this.setState(() {
                              feeDescription = 'Slow >';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          });
        });
  }

  buildPreviewButton(BuildContext context, FeeObject feeObjRaw, dynamic bitcoinPrice, String currency) {
    if (showFinalTxDetails) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Material(
            child: Ink(
              decoration: BoxDecoration(color: Colors.amber),
              child: InkWell(
                onTap: () async {
                  final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
                  // Show loading dialog
                  showModal(
                    context: context,
                    configuration: FadeScaleTransitionConfiguration(),
                    builder: (BuildContext context) {
                      return attemptBuildTransactionDialog(context);
                    },
                  );

                  dynamic feeChosen;

                  if (this.feeSelection == 0) {
                    feeChosen = feeObjRaw.fast;
                  } else if (this.feeSelection == 1) {
                    feeChosen = feeObjRaw.medium;
                  } else if (this.feeSelection == 2) {
                    feeChosen = feeObjRaw.slow;
                  }

                  final int satoshiAmountToSend = double.parse(satsAmountController.text).toInt();

                  dynamic txHexOrError = await bitcoinService.coinSelection(
                    satoshiAmountToSend,
                    feeChosen,
                    recipientAddressTextController.text,
                  );

                  if (txHexOrError is int) {
                    // Here, we assume that transaction crafting returned an error
                    if (txHexOrError == 1) {
                      Navigator.pop(context);
                      showModal(
                        context: context,
                        configuration: FadeScaleTransitionConfiguration(),
                        builder: (BuildContext context) {
                          return notEnoughBalanceDialog(context);
                        },
                      );
                    } else if (txHexOrError == 2) {
                      Navigator.pop(context);
                      showModal(
                        context: context,
                        configuration: FadeScaleTransitionConfiguration(),
                        builder: (BuildContext context) {
                          return notEnoughForFeesDialog(context);
                        },
                      );
                    }
                  } else {
                    Navigator.pop(context);
                    showModal(
                      context: context,
                      configuration: FadeScaleTransitionConfiguration(),
                      builder: (BuildContext context) {
                        return PreviewTransactionSubview(
                          hex: txHexOrError['hex'],
                          currency: currency,
                          bitcoinPrice: bitcoinPrice,
                          denomination: currentDenominationSelection,
                          feeInSatoshis: txHexOrError['fee'],
                          recipient: txHexOrError['recipient'],
                          recipientAmountInSatoshis: txHexOrError['recipientAmt'],
                        );
                      },
                    );
                  }
                  print(txHexOrError.toString());
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 20,
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      Icon(Icons.remove_red_eye, color: Color(0xff121212)),
                      SizedBox(width: 12),
                      Text(
                        'Preview Transaction',
                        style: TextStyle(color: Color(0xff121212), fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

// Send view helper functions

Text formatAddress(String address) {
  final String formatted = address.substring(0, 4) + '...' + address.substring(address.length - 4);
  return Text(
    formatted,
    style: TextStyle(color: Colors.cyanAccent),
  );
}

String validateAddress(String address) {
  Pattern pattern = r'^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(address))
    return 'Invalid Address';
  else
    return null;
}

Material buildAmountViewLoading() {
  return Material(
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    ),
  );
}

AlertDialog exactAmountDialog(BuildContext _) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: Text(
      'Not enough bitcoin',
      style: TextStyle(color: Colors.white),
    ),
    content: Text(
      'You cannot spend an amount exactly equal to what you currently have spendable. You must leave some over to pay for the transaction fee.',
      style: TextStyle(color: Colors.white),
    ),
    actions: [
      FlatButton(
        onPressed: () => Navigator.pop(_),
        child: Text(
          'OK',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      )
    ],
  );
}

AlertDialog zeroAmountDialog(BuildContext _) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: Text(
      'Not enough bitcoin',
      style: TextStyle(color: Colors.white),
    ),
    content: Text(
      'You cannot spend nothing. Please modify amount and remember to leave some over for transaction fees.',
      style: TextStyle(color: Colors.white),
    ),
    actions: [
      FlatButton(
        onPressed: () => Navigator.pop(_),
        child: Text(
          'OK',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      )
    ],
  );
}

AlertDialog tooMuchDialog(BuildContext _) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: Text(
      'Not enough bitcoin',
      style: TextStyle(color: Colors.white),
    ),
    content: Text(
      'You cannot spend an amount more than what you currently have spendable. Please modify amount and remember to leave some over for transaction fees.',
      style: TextStyle(color: Colors.white),
    ),
    actions: [
      FlatButton(
        onPressed: () => Navigator.pop(_),
        child: Text(
          'OK',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      )
    ],
  );
}

AlertDialog attemptBuildTransactionDialog(BuildContext _) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 12),
        Text('Please wait...', style: TextStyle(color: Colors.white)),
      ],
    ),
    content: Text(
      'Attempting to build transaction',
      style: TextStyle(color: Colors.white),
    ),
  );
}

AlertDialog notEnoughForFeesDialog(BuildContext _) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: Text('Not enough remainder', style: TextStyle(color: Colors.white)),
    content: Text(
      'You aren\'t leaving enough over in your wallet to pay for transaction fees. Please modify amount and try again.',
      style: TextStyle(color: Colors.white),
    ),
    actions: [FlatButton(onPressed: () => Navigator.pop(_), child: Text('OK'))],
  );
}

AlertDialog notEnoughBalanceDialog(BuildContext _) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: Text('Not enough Bitcoin', style: TextStyle(color: Colors.white)),
    content: Text(
      'You don\'t the amount of Bitcoin that you\'re trying to spend. Please modify amount and try again.',
      style: TextStyle(color: Colors.white),
    ),
    actions: [FlatButton(onPressed: () => Navigator.pop(_), child: Text('OK'))],
  );
}

class NumberRemoveExtraDotFormatter extends TextInputFormatter {
  NumberRemoveExtraDotFormatter({this.decimalRange = 8}) : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String nValue = newValue.text;
    TextSelection nSelection = newValue.selection;

    Pattern p = RegExp(r'(\d+\.?)|(\.?\d+)|(\.?)');
    nValue = p.allMatches(nValue).map<String>((Match match) => match.group(0)).join();

    if (nValue.startsWith('.')) {
      nValue = '0.';
    } else if (nValue.contains('.')) {
      if (nValue.substring(nValue.indexOf('.') + 1).length > decimalRange) {
        nValue = oldValue.text;
      } else {
        if (nValue.split('.').length > 2) {
          List<String> split = nValue.split('.');
          nValue = split[0] + '.' + split[1];
        }
      }
    }

    nSelection = newValue.selection.copyWith(
      baseOffset: math.min(nValue.length, nValue.length + 1),
      extentOffset: math.min(nValue.length, nValue.length + 1),
    );

    return TextEditingValue(text: nValue, selection: nSelection, composing: TextRange.empty);
  }
}

class PreviewTransactionSubview extends StatefulWidget {
  final String hex;
  final String recipient;
  final int recipientAmountInSatoshis;
  final int feeInSatoshis;
  final int denomination;
  final dynamic bitcoinPrice;
  final String currency;

  const PreviewTransactionSubview(
      {Key key,
      this.hex,
      this.recipient,
      this.recipientAmountInSatoshis,
      this.feeInSatoshis,
      this.denomination,
      this.bitcoinPrice,
      this.currency})
      : super(key: key);

  @override
  _PreviewTransactionSubviewState createState() => _PreviewTransactionSubviewState();
}

class _PreviewTransactionSubviewState extends State<PreviewTransactionSubview> {
  int viewDenomination;
  RoundedLoadingButtonController submitButtonController;

  @override
  void initState() {
    viewDenomination = widget.denomination;
    submitButtonController = new RoundedLoadingButtonController();
    super.initState();
  }

  void pushtx() async {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
    // await Future.delayed(Duration(milliseconds: 2000)).then((value) => submitButtonController.success());
    await bitcoinService.submitHexToNetwork(widget.hex).then((booleanResponse) async {
      if (booleanResponse == true) {
        submitButtonController.success();
        await Future.delayed(Duration(milliseconds: 1000)).then((value) {
          final nav = Navigator.of(context);
          nav.pop();
          nav.pop();
        });
      } else {
        submitButtonController.error();
        await Future.delayed(Duration(milliseconds: 1000)).then((value) {
          final nav = Navigator.of(context);
          nav.pop();
          nav.pop();
        });
      }
    });
  }

  buildAmount() {
    if (viewDenomination == 0) {
      return (widget.recipientAmountInSatoshis / 100000000).toString() + ' BTC';
    } else if (viewDenomination == 1) {
      return (widget.recipientAmountInSatoshis).toString() + ' sats';
    } else if (viewDenomination == 2) {
      final valueRaw = (widget.recipientAmountInSatoshis / 100000000) * widget.bitcoinPrice;
      FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: valueRaw);
      return currencyMap[widget.currency] + fmf.output.nonSymbol;
    }
  }

  buildFees() {
    if (viewDenomination == 0) {
      return (widget.feeInSatoshis / 100000000).toString() + ' BTC';
    } else if (viewDenomination == 1) {
      return (widget.feeInSatoshis).toString() + ' sats';
    } else if (viewDenomination == 2) {
      final valueRaw = (widget.feeInSatoshis / 100000000) * widget.bitcoinPrice;
      FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: valueRaw);
      return currencyMap[widget.currency] + fmf.output.nonSymbol;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 100,
        color: Colors.black,
        child: RoundedLoadingButton(
          controller: submitButtonController,
          onPressed: pushtx,
          color: Colors.amber,
          valueColor: Color(0xff121212),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, color: Color(0xff121212)),
              SizedBox(width: 12),
              Text('Submit transaction', style: TextStyle(color: Color(0xff121212))),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Material(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 16),
            Center(
              child: Text(
                'Confirm transaction details',
                textScaleFactor: 1.5,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 32),
            ListTile(
              title: Text('Recipient:', style: TextStyle(color: Colors.white)),
              trailing: formatAddress(widget.recipient),
              onTap: () {},
            ),
            ListTile(
              title: Text('Amount:', style: TextStyle(color: Colors.white)),
              trailing: Text(
                buildAmount(),
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onTap: () {
                setState(() {
                  if (viewDenomination == 0) {
                    viewDenomination = 1;
                  } else if (viewDenomination == 1) {
                    viewDenomination = 2;
                  } else if (viewDenomination == 2) {
                    viewDenomination = 0;
                  }
                });
              },
            ),
            ListTile(
              title: Text('Fee (on-chain):', style: TextStyle(color: Colors.white)),
              trailing: Text(
                buildFees(),
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onTap: () {
                setState(() {
                  if (viewDenomination == 0) {
                    viewDenomination = 1;
                  } else if (viewDenomination == 1) {
                    viewDenomination = 2;
                  } else if (viewDenomination == 2) {
                    viewDenomination = 0;
                  }
                });
              },
            ),
            ListTile(
              title: Text('Copy transaction hex', style: TextStyle(color: Colors.cyanAccent)),
              onTap: () {
                Clipboard.setData(new ClipboardData(text: widget.hex));
                Toast.show(
                  'Transaction hex copied to clipboard',
                  context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.BOTTOM,
                );
              },
            ),
            ListTile(
              title: Text('Save hex offline', style: TextStyle(color: Colors.grey)),
              onTap: () {
                Toast.show('Feature coming soon', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              },
            )
          ],
        ),
      ),
    );
  }
}
