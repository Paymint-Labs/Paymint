import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:paymint/models/models.dart';
import 'package:marquee/marquee.dart';
import 'dart:convert';
import 'package:paymint/services/globals.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dark_theme_script.dart' show darkThemeScript;

class WalletView extends StatefulWidget {
  WalletView({Key key}) : super(key: key);

  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff121212),
        body: Column(
          children: <Widget>[
            SizedBox(height: 8),

            // Market information Marquee widget

            FutureBuilder(
              future: bitcoinService.marketInfo,
              builder: (BuildContext context, AsyncSnapshot<String> marketInfo) {
                if (marketInfo.connectionState == ConnectionState.done) {
                  return Container(
                    height: 16,
                    child: Marquee(
                      fadingEdgeStartFraction: 0.2,
                      fadingEdgeEndFraction: 0.2,
                      text: marketInfo.data ?? 'Unable to fetch Market metadata    ',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return Container(
                    height: 16,
                    child: Center(
                      child: Text(
                        'Fetching market metadata...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
            ),

            // UtxoData Widget - Top half of Wallet View

            Container(
              height: (MediaQuery.of(context).size.height - 46) / 3,
              child: FutureBuilder(
                future: bitcoinService.utxoData,
                builder: (BuildContext context, AsyncSnapshot<UtxoData> utxoData) {
                  if (utxoData.connectionState == ConnectionState.done) {
                    if (utxoData == null || utxoData.hasError) {
                      return Container(
                        child: Center(
                          child: Text(
                            'Unable to fetch balance data.\nPlease check connection',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          utxoData.data.totalUserCurrency,
                          textScaleFactor: 2.7,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          formatSatoshiBalance(utxoData.data.satoshiBalance),
                          textScaleFactor: 1.5,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  } else {
                    return buildBalanceInformationLoadingWidget();
                  }
                },
              ),
            ),

            // Charting widget - bottom half of Wallet View

            Expanded(
              child: FutureBuilder(
                future: bitcoinService.chartData,
                builder: (BuildContext context, AsyncSnapshot<ChartModel> chartData) {
                  if (chartData.connectionState == ConnectionState.done) {
                    return FutureBuilder(
                      future: bitcoinService.currency,
                      builder: (BuildContext context, AsyncSnapshot<String> currency) {
                        if (currency.connectionState == ConnectionState.done) {
                          if (chartData == null || chartData.hasError) {
                            return Container(
                              child: Center(
                                child: Text(
                                  'Cannot fetch chart data. Please check connection',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                          return FutureBuilder(
                            future: bitcoinService.bitcoinPrice,
                            builder: (BuildContext context, AsyncSnapshot<dynamic> price) {
                              if (price.connectionState == ConnectionState.done) {
                                final symbol = currency.data;
                                final midDate = chartData.data.xAxis[chartData.data.xAxis.length - 35];

                                FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: price.data + .00);

                                final String displayPrice = currencyMap[symbol] + fmf.output.nonSymbol ?? '???';

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Echarts(
                                    extensions: [darkThemeScript],
                                    theme: 'dark',
                                    option: json.encode({
                                      "title": {"text": "BTC/$symbol @ $displayPrice", "left": 15},
                                      "tooltip": {
                                        "trigger": 'axis',
                                        "axisPointer": {"type": 'cross'}
                                      },
                                      "xAxis": {"data": chartData.data.xAxis},
                                      "yAxis": {"show": false, "scale": true},
                                      "dataZoom": buildDataZoomOptions(midDate),
                                      "series": [
                                        {
                                          "type": 'k',
                                          "itemStyle": buildCandleStickColorData(),
                                          "data": chartData.data.candleData,
                                        }
                                      ]
                                    }),
                                  ),
                                );
                              } else {
                                return Center(child: buildChartLoadingWidget());
                              }
                            },
                          );
                        } else {
                          return Center(child: buildChartLoadingWidget());
                        }
                      },
                    );
                  } else {
                    return Center(child: buildChartLoadingWidget());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wallet View Helper Functions

/// Adds necessary commas (,) to [satoshiBalance] and returns string
///
/// >>> formatSatoshiBalance(123456)
/// '123,456'
String formatSatoshiBalance(int satoshiBalance) {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  return satoshiBalance.toString().replaceAllMapped(reg, mathFunc) + ' sats';
}

Widget buildBalanceInformationLoadingWidget() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Fetching balance...',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: 150,
          child: LinearProgressIndicator(),
        )
      ],
    ),
  );
}

Widget buildChartLoadingWidget() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Fetching chart data...',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: 150,
          child: LinearProgressIndicator(),
        )
      ],
    ),
  );
}

List buildDataZoomOptions(String midValue) {
  return [
    {
      "startValue": midValue,
      "textStyle": {"color": '#8392A5'},
      "handleIcon":
          'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
      "handleSize": '80%',
      "dataBackground": {
        "areaStyle": {"color": '#8392A5'},
        "lineStyle": {"opacity": 0.8, "color": '#8392A5'}
      },
      "handleStyle": {
        "color": '#fff',
        "shadowBlur": 3,
        "shadowColor": 'rgba(0, 0, 0, 0.6)',
        "shadowOffsetX": 2,
        "shadowOffsetY": 2
      }
    },
    {"type": 'inside'}
  ];
}

Map<String, String> buildCandleStickColorData() {
  return {"color": '#15F4EE', "color0": '#FF0266', "borderColor": '#15F4EE', "borderColor0": '#FF0266'};
}
