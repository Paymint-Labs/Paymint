import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/services.dart';
import 'package:paymint/components/globals.dart';
import 'package:animations/animations.dart';

// Change currency function should be in the BitcoinService Provider class to update value
// exposed via provider. Currency Map is imported with globals.

class CurrencyChangeView extends StatefulWidget {
  CurrencyChangeView({Key key}) : super(key: key);

  @override
  _CurrencyChangeViewState createState() => _CurrencyChangeViewState();
}

class _CurrencyChangeViewState extends State<CurrencyChangeView> {
  final List<String> currencyList = [
    "AED",
    "AUD",
    "CAD",
    "CHF",
    "CNY",
    "EUR",
    "GBP",
    "HKD",
    "INR",
    "JPY",
    "KRW",
    "PHP",
    "SGD",
    "TRY",
    "USD",
    "XAU"
  ];

  @override
  Widget build(BuildContext context) {
    final BitcoinService btcService = Provider.of<BitcoinService>(context);
    return FutureBuilder(
      future: btcService.currency,
      builder: (BuildContext context, AsyncSnapshot<String> currency) {
        if (currency.connectionState == ConnectionState.done) {
          return _buildChangeCurrencyView(context, currency);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _buildChangeCurrencyView(
      BuildContext context, AsyncSnapshot<String> currency) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Select currency', style: GoogleFonts.rubik()),
      ),
      body: ListView.builder(
        itemCount: currencyList.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCurrencyListTile(index, currency.data);
        },
      ),
    );
  }

  ListTile _buildCurrencyListTile(int index, String selectedCurrency) {
    if (currencyList[index] == selectedCurrency) {
      final String symbol = currencyMap[currencyList[index]];
      return ListTile(
        title: Text(selectedCurrency + ' ~ $symbol'),
        trailing: Icon(
          Icons.check,
          color: Colors.blue,
        ),
        onTap: () {},
      );
    } else {
      final String symbol = currencyMap[currencyList[index]];
      return ListTile(
        title: Text(currencyList[index] + ' ~ $symbol'),
        onTap: () async {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
            builder: (BuildContext context) {
              return _currencySwitchDialog(currencyList[index]);
            }
          );
          final BitcoinService btcService = Provider.of<BitcoinService>(context);
          await btcService.changeCurrency(currencyList[index]);
          await btcService.refreshWalletData();
          Navigator.pop(context);
        },
      );
    }
  }

  _currencySwitchDialog(String newCurrency) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Switching currency...'),
        ],
      ),
      content: Text("Please wait while we refresh wallet data in $newCurrency"),
    ); 
  }
}
