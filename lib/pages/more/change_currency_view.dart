import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/services.dart';

class CurrencyChangeView extends StatefulWidget {
  CurrencyChangeView({Key key}) : super(key: key);

  @override
  _CurrencyChangeViewState createState() => _CurrencyChangeViewState();
}

class _CurrencyChangeViewState extends State<CurrencyChangeView> {
  final List<String> currencyList = [""];

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

  _buildChangeCurrencyView(BuildContext context, AsyncSnapshot<String> currency) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Select currency', style: GoogleFonts.rubik()),
      ),
      body: ListView.builder(
        itemCount: currencyList.length,
        itemBuilder: (BuildContext context, int index) {
        return ;
       },
      ),
    );
  }

  ListTile _buildCurrencyListTile(int index) {

  }
}
