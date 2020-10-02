import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:paymint/services/globals.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/utils/currency_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:paymint/services/services.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InvestView extends StatefulWidget {
  @override
  _InvestViewState createState() => _InvestViewState();
}

class _InvestViewState extends State<InvestView> with TickerProviderStateMixin {
  AnimationController _animationController;

  final GlobalKey<InnerDrawerState> _drawerKey = GlobalKey<InnerDrawerState>();

  final List<String> countries = countryList;
  final List<String> countriesDuplicate = new List();
  TextEditingController searchEditingController = TextEditingController();

  Future<String> fetchCountry() async {
    return await CurrencyUtilities.fetchBankingCountry();
  }

  void _toggleRightDrawer() {
    _drawerKey.currentState.toggle(direction: InnerDrawerDirection.end);
  }

  void _toggleLeftDrawer() {
    _drawerKey.currentState.toggle(direction: InnerDrawerDirection.start);
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(countriesDuplicate);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((String item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        countries.clear();
        countries.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        countries.clear();
        countries.addAll(countriesDuplicate);
      });
    }
  }

  buildListTilesForBuy(String country, String currentAddress) {
    ListTile cardListTile = ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(backgroundColor: Colors.greenAccent),
          Image.asset(
            'assets/images/card.png',
            height: 22,
          )
        ],
      ),
      title: Text(
        'Debit/Credit Card',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Low Limits, Instant Delivery',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.cyanAccent,
      ),
      onTap: () async {
        final requestBody = {
          "url":
              "https://buy.moonpay.io?apiKey=pk_live_uO38X08NU7lveH96y43ZdHrtcyi6J7X&currencyCode=btc&walletAddress=$currentAddress",
        };

        try {
          final response = await http.post(
            'https://us-central1-paymint.cloudfunctions.net/api/signPurchaseRequest',
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          );

          print(json.decode(response.body));

          if (response.statusCode == 200) {
            FlutterWebBrowser.openWebPage(
              url: json.decode(response.body),
              androidToolbarColor: Color(0xff121212),
              safariVCOptions: SafariViewControllerOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: Colors.green,
                preferredControlTintColor: Colors.amber,
                dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                modalPresentationCapturesStatusBarAppearance: true,
              ),
            );
          }
        } catch (e) {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(),
            builder: (context) => showErrorDialog(context, e.toString()),
          );
        }
      },
    );

    ListTile bankListTile = ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(backgroundColor: Colors.greenAccent),
          Image.asset(
            'assets/images/bank.png',
            height: 22,
          )
        ],
      ),
      title: Text(
        'Bank Transfer',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'High Limits, Slow Delivery',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.cyanAccent,
      ),
      onTap: () async {
        final x = Uri.encodeComponent('sepa_bank_transfer,gbp_bank_transfer');

        final requestBody = {
          "url":
              "https://buy.moonpay.io?apiKey=pk_live_uO38X08NU7lveH96y43ZdHrtcyi6J7X&enabledPaymentMethods=$x&currencyCode=btc&walletAddress=$currentAddress",
        };

        try {
          final response = await http.post(
            'https://us-central1-paymint.cloudfunctions.net/api/signPurchaseRequest',
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          );

          print(json.decode(response.body));

          if (response.statusCode == 200) {
            FlutterWebBrowser.openWebPage(
              url: json.decode(response.body),
              androidToolbarColor: Color(0xff121212),
              safariVCOptions: SafariViewControllerOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: Colors.green,
                preferredControlTintColor: Colors.amber,
                dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                modalPresentationCapturesStatusBarAppearance: true,
              ),
            );
          }
        } catch (e) {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(),
            builder: (context) => showErrorDialog(context, e.toString()),
          );
        }
      },
    );

    // Xanpool custom conditions
    if (country == 'Hong Kong') {
      return [cardListTile];
    } else if (country == 'India') {
      return [cardListTile];
    } else if (country == 'Philipines') {
      return [cardListTile];
    } else if (country == 'Malaysia') {
      return [cardListTile];
    } else if (country == 'Singapore') {
      return [cardListTile];
    } else if (country == 'Vietnam') {
      return [cardListTile];
    } else if (country == 'Indonesia') {
      return [cardListTile];
    } else if (country == 'Thailand') {
      return [cardListTile];

      // EU (BANK for moonpay) custom conditions
    } else if (country == 'Austria') {
      return [cardListTile, bankListTile];
    } else if (country == 'Belgium') {
      return [cardListTile, bankListTile];
    } else if (country == 'Croatia') {
      return [cardListTile, bankListTile];
    } else if (country == 'Cyprus') {
      return [cardListTile, bankListTile];
    } else if (country == 'Czechia (Czech Republic)') {
      return [cardListTile, bankListTile];
    } else if (country == 'Denmark') {
      return [cardListTile, bankListTile];
    } else if (country == 'Estonia') {
      return [cardListTile, bankListTile];
    } else if (country == 'Finland') {
      return [cardListTile, bankListTile];
    } else if (country == 'France') {
      return [cardListTile, bankListTile];
    } else if (country == 'Germany') {
      return [cardListTile, bankListTile];
    } else if (country == 'Greece') {
      return [cardListTile, bankListTile];
    } else if (country == 'Hungary') {
      return [cardListTile, bankListTile];
    } else if (country == 'Iceland') {
      return [cardListTile, bankListTile];
    } else if (country == 'Italy') {
      return [cardListTile, bankListTile];
    } else if (country == 'Latvia') {
      return [cardListTile, bankListTile];
    } else if (country == 'Lithuania') {
      return [cardListTile, bankListTile];
    } else if (country == 'Luxembourg') {
      return [cardListTile, bankListTile];
    } else if (country == 'Malta') {
      return [cardListTile, bankListTile];
    } else if (country == 'Netherlands') {
      return [cardListTile, bankListTile];
    } else if (country == 'Poland') {
      return [cardListTile, bankListTile];
    } else if (country == 'Portugal') {
      return [cardListTile, bankListTile];
    } else if (country == 'Romania') {
      return [cardListTile, bankListTile];
    } else if (country == 'Slovakia') {
      return [cardListTile, bankListTile];
    } else if (country == 'Slovenia') {
      return [cardListTile, bankListTile];
    } else if (country == 'Spain') {
      return [cardListTile, bankListTile];
    } else if (country == 'Sweden') {
      return [cardListTile, bankListTile];
    } else if (country == 'United Kingdom') {
      return [cardListTile, bankListTile];
    } else {
      return [cardListTile];
    }
  }

  Widget buildListTilesForSell(String country, String currentAddress) {
    ListTile bankListTile = ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(backgroundColor: Colors.greenAccent),
          Image.asset(
            'assets/images/bank.png',
            height: 22,
          )
        ],
      ),
      title: Text(
        'Bank Transfer',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'High Limits, Slow Delivery',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.cyanAccent,
      ),
      onTap: () async {
        final requestBody = {
          "url":
              "https://sell.moonpay.io?apiKey=pk_live_uO38X08NU7lveH96y43ZdHrtcyi6J7X&baseCurrencyCode=btc&refundWalletAddress=$currentAddress",
        };

        try {
          final response = await http.post(
            'https://us-central1-paymint.cloudfunctions.net/api/signPurchaseRequest',
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 200) {
            FlutterWebBrowser.openWebPage(
              url: json.decode(response.body),
              androidToolbarColor: Color(0xff121212),
              safariVCOptions: SafariViewControllerOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: Colors.green,
                preferredControlTintColor: Colors.amber,
                dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                modalPresentationCapturesStatusBarAppearance: true,
              ),
            );
          }
        } catch (e) {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(),
            builder: (context) => showErrorDialog(context, e.toString()),
          );
        }
      },
    );

    /// Uncomment the countries below when EU sells are enabled by MoonPay

    if (country == 'xxx') {
      return ListView(
        children: [bankListTile],
      );
      // } else if (country == 'Austria') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Belgium') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Croatia') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Cyprus') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Czechia (Czech Republic)') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Denmark') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Estonia') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Finland') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'France') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Germany') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Greece') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Hungary') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Iceland') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Italy') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Latvia') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Lithuania') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Luxembourg') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Malta') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Netherlands') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Poland') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Portugal') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Romania') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Slovakia') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Slovenia') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Spain') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'Sweden') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
      // } else if (country == 'United Kingdom') {
      //   return ListView(
      //     children: [bankListTile],
      //   );
    } else {
      return Container(
        child: Center(
          child: Text(
            'We do not support selling Bitcoin for this region yet.\nCome check again soon!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _animationController.repeat(reverse: true);
    for (var i = 0; i < countryList.length; i++) {
      countriesDuplicate.add(countryList[i]);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return InnerDrawer(
      swipeChild: true,
      key: _drawerKey,
      onTapClose: true,
      swipe: true,
      offset: IDOffset.horizontal(1),
      scale: IDOffset.horizontal(1),
      rightAnimationType: InnerDrawerAnimation.quadratic,
      colorTransitionChild: Colors.cyan,

      // Payment method view
      rightChild: FutureBuilder(
        future: fetchCountry(),
        builder: (BuildContext context, AsyncSnapshot<String> country) {
          if (country.connectionState == ConnectionState.done) {
            return FutureBuilder(
              future: bitcoinService.currentReceivingAddress,
              builder: (BuildContext context, AsyncSnapshot<String> address) {
                if (address.connectionState == ConnectionState.done) {
                  return SafeArea(
                    child: Scaffold(
                      backgroundColor: Color(0xff121212),
                      appBar: AppBar(
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.cyanAccent,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text(
                          'Payment Methods - ' + country.data,
                          style: GoogleFonts.rubik(color: Colors.white),
                        ),
                      ),
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Buy Bitcoin',
                              textScaleFactor: 1.25,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: buildListTilesForBuy(country.data, address.data),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Sell Bitcoin',
                              textScaleFactor: 1.25,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: buildListTilesForSell(country.data, address.data)),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container(
                    color: Color(0xff121212),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
          } else {
            return Container(
              color: Color(0xff121212),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),

      // Country selection view
      leftChild: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xff121212),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Please select the country that you bank in:',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: searchEditingController,
                decoration: InputDecoration(
                  labelText: "Search",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => filterSearchResults(value),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        countries[index],
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        setState(() {});
                        await CurrencyUtilities.setPreferredCurrency(countries[index]);
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),

      // Main invest view
      scaffold: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xff121212),
          bottomNavigationBar: Container(
            height: 100,
            child: FutureBuilder(
              future: fetchCountry(),
              builder: (BuildContext context, AsyncSnapshot<String> country) {
                if (country.connectionState == ConnectionState.done) {
                  return Container(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: Text(
                          'Where do you bank?',
                          style: TextStyle(color: Colors.grey),
                          textScaleFactor: 0.75,
                        ),
                        subtitle: Text(
                          country.data,
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 1.25,
                        ),
                        trailing: Icon(Icons.list, color: Colors.cyanAccent),
                        onTap: () => _toggleLeftDrawer(),
                      ),
                    ),
                    // color: Colors.red,
                  );
                } else {
                  return Container(
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 16,
                        child: LinearProgressIndicator(),
                      ),
                    ),
                  );
                }
              },
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
                          onTap: () => _toggleRightDrawer(),
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
                                    'Is your internet connection active?',
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(
                        '(Tap on the Bitcoin logo to select your payment method after choosing your country below)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Center buildLoadingWidget() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

AlertDialog showErrorDialog(BuildContext context, String error) {
  return AlertDialog(
    title: Text(
      'Error',
      style: TextStyle(color: Colors.white),
    ),
    content: Text(
      error,
      style: TextStyle(color: Colors.white),
    ),
    actions: [FlatButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
  );
}
