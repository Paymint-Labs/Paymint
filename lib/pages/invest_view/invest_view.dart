import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:paymint/services/globals.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:paymint/services/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class InvestView extends StatefulWidget {
  @override
  _InvestViewState createState() => _InvestViewState();
}

class _InvestViewState extends State<InvestView> with TickerProviderStateMixin {
  AnimationController _animationController;
  var sliderVal = 20.0;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _animationController.repeat(reverse: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff121212),
        bottomNavigationBar: Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 50,
                      width: 70,
                      color: Colors.black,
                    ),
                  ),
                  Image.asset(
                    'assets/images/mastercard.jpg',
                    height: 25,
                  ),
                ],
              ),
              SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 50,
                      width: 70,
                      color: Colors.black,
                    ),
                  ),
                  Image.asset(
                    'assets/images/visa.png',
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => showPaymentOptionsModal(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.green,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Invest',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: ScaleTransition(
                      scale: Tween(begin: 0.75, end: 1.0).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticOut,
                      )),
                      child: GestureDetector(
                        onTap: () => showPurchaseModal(),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Container(
                                height: 70,
                                width: 70,
                                color: Colors.white,
                              ),
                            ),
                            Image.asset(
                              'assets/images/btc.png',
                              height: 70.0,
                              width: 70.0,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  FutureBuilder(
                    future: bitcoinService.currency,
                    builder: (BuildContext context, AsyncSnapshot<String> currencyData) {
                      if (currencyData.connectionState == ConnectionState.done) {
                        return FutureBuilder(
                          future: bitcoinService.bitcoinPrice,
                          builder: (BuildContext context, AsyncSnapshot<dynamic> priceData) {
                            if (priceData.connectionState == ConnectionState.done) {
                              if (priceData.hasError || priceData.data == null) {
                                // Build price load error widget below later
                                return Text(
                                  'Stack sats with Paymint',
                                  style: TextStyle(color: Colors.white),
                                );
                              }

                              FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: priceData.data);
                              final String displayPriceNonSymbol = fmf.output.nonSymbol;
                              // Triggers code below when no errors are found :D
                              return Text(
                                currencyMap[currencyData.data] + displayPriceNonSymbol,
                                style: TextStyle(color: Colors.white),
                                textScaleFactor: 1.5,
                              );
                            } else {
                              return buildLoadingWidget();
                            }
                          },
                        );
                      } else {
                        return buildLoadingWidget();
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    '(Tap the Bitcoin logo to purchase some\nBitcoin directly into your wallet)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showPurchaseModal() async {
    await Permission.camera.request();

    showCupertinoModalBottomSheet(
      context: context,
      bounce: true,
      expand: true,
      builder: (context, scrollController) {
        return InAppWebView(
          initialUrl: 'https://buy.moonpay.io/',
        );
      },
    );
  }

  showPaymentOptionsModal() {
    showCupertinoModalBottomSheet(
      context: context,
      bounce: true,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'We offer Bitcoin purchasing via our partners, MoonPay. MoonPay accepts most major credit cards including Visa, MasterCard, and Maestro.\n\nAlso, they accept some debit cards that are prepaid or virtual, including Apple Pay.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

Center buildLoadingWidget() {
  return Center(
    child: CircularProgressIndicator(),
  );
}
