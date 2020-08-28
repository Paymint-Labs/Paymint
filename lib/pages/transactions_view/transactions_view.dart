import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:paymint/services/services.dart';
import 'package:paymint/models/models.dart';
import 'package:paymint/services/globals.dart';
import 'package:toast/toast.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:paymint/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionsView extends StatefulWidget {
  @override
  _TransactionsViewState createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final GlobalKey<InnerDrawerState> _drawerKey = GlobalKey<InnerDrawerState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleDrawer() {
    _drawerKey.currentState.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return InnerDrawer(
      key: _drawerKey,
      onTapClose: true,
      swipe: true,
      offset: IDOffset.horizontal(1),
      scale: IDOffset.horizontal(1),
      rightAnimationType: InnerDrawerAnimation.quadratic,
      colorTransitionChild: Colors.cyan,

      // Outputs View Scaffold

      rightChild: Scaffold(
        backgroundColor: Color(0xff121212),
        appBar: AppBar(
          backgroundColor: Color(0xff121212),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color(0xff81D4FA),
            onPressed: _toggleDrawer,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.blur_circular),
              color: Color(0xff81D4FA),
              onPressed: () {},
            )
          ],
          title: Text(
            'Wallet Outputs',
            style: GoogleFonts.rubik(color: Colors.white),
          ),
        ),
        body: FutureBuilder(
          future: bitcoinService.utxoData,
          builder: (BuildContext context, AsyncSnapshot<UtxoData> outputData) {
            if (outputData.connectionState == ConnectionState.done) {
              return _buildSecurityView(outputData, context);
            } else {
              return LinearProgressIndicator();
            }
          },
        ),
      ),

      // Transactions View Scaffold

      scaffold: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xff121212),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          backgroundColor: Color(0xff81D4FA),
          onPressed: () {},
        ),
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.all_out),
              color: Color(0xff81D4FA),
              onPressed: () {
                _toggleDrawer();
              },
            )
          ],
          title: Text(
            'Transactions',
            style: GoogleFonts.rubik(color: Colors.white),
          ),
        ),
        body: FutureBuilder(
          future: bitcoinService.transactionData,
          builder: (BuildContext context, AsyncSnapshot<TransactionData> txData) {
            if (txData.connectionState == ConnectionState.done) {
              return _buildActivityView(context, txData);
            } else {
              return LinearProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

// Transaction View Helper Functions

Widget _buildActivityView(BuildContext context, AsyncSnapshot<TransactionData> txData) {
  // Assuming here that the txData list is empty

  if (txData.data.txChunks.length == 0) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'No transactions found :(',
          textScaleFactor: 1.1,
          style: TextStyle(color: Colors.white),
        ),
      ],
    ));
  } else {
    // Assuming here that #transactions >= 1

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ListView.builder(
        itemCount: txData.data.txChunks.length,
        itemBuilder: (BuildContext context, int index) {
          return StickyHeader(
            header: Container(
                color: Color(0xff121212),
                padding: EdgeInsets.fromLTRB(10, 0, 0, 8),
                child: Text(
                  extractDateFromTimestamp(txData.data.txChunks[index].timestamp ?? 0),
                  textScaleFactor: 1.25,
                  style: TextStyle(color: Colors.white),
                )),
            content: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: _buildTransactionChildLists(txData.data.txChunks[index].transactions),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
            ),
          );
        },
      ),
    );
  }
}

List<Widget> _buildTransactionChildLists(List<Transaction> txChildren) {
  final List<Widget> finalListView = [];

  final satoshisToBtc = (int satoshiAmount) => (satoshiAmount / 100000000).toString();

  for (var txIndex = 0; txIndex < txChildren.length; txIndex++) {
    final tx = txChildren[txIndex];

    // Check if transaction is unconfirmed first
    if (tx.confirmedStatus == false) {
      if (tx.txType == 'Sent') {
        finalListView.add(
          OutgoingTransactionListTile(satoshisToBtc(tx.amount), tx.worthNow),
        );
      } else if (tx.txType == 'Received') {
        finalListView.add(
          IncomingTransactionListTile(satoshisToBtc(tx.amount), tx.worthNow),
        );
      }
    } else {
      // Triggers if the transaction has at least 1 confirmation on mainnet
      if (txChildren[txIndex].txType == 'Sent') {
        finalListView.add(SendListTile(
          amount: satoshisToBtc(tx.amount),
          currentValue: tx.worthNow,
          previousValue: tx.worthAtBlockTimestamp,
          tx: txChildren[txIndex],
        ));
      } else if (txChildren[txIndex].txType == 'Received') {
        finalListView.add(ReceiveListTile(
          amount: satoshisToBtc(tx.amount),
          currentValue: tx.worthNow,
          previousValue: tx.worthAtBlockTimestamp,
          tx: txChildren[txIndex],
        ));
      }
    }
  }
  finalListView.add(SizedBox(height: 13));
  return finalListView;
}

String extractDateFromTimestamp(int timestamp) {
  if (timestamp == 0) {
    return 'Now...';
  }

  final int weekday = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).weekday;
  final int day = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).day;
  final int month = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).month;
  final int year = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).year;

  return monthMap[month] + ' $day, $year - ' + weekDayMap[weekday];
}

// Wallet Output View Helper Functions

Widget _buildSecurityView(AsyncSnapshot<UtxoData> utxoData, BuildContext context) {
  if (utxoData.data.unspentOutputArray.length == 0) {
    return Center(
      child: Text(
        'No outputs found :(',
        style: TextStyle(color: Colors.white),
      ),
    );
  } else {
    return SingleChildScrollView(
      child: Column(
        children: _buildSecurityListView(context),
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}

List<Widget> _buildSecurityListView(BuildContext context) {
  List<UtxoObject> _utxoList = Provider.of<BitcoinService>(context).allOutputs;

  List<Widget> _finalList = [];

  if (_utxoList.length == 0) {
    // For modifying no utxos empty state if necessary. Add widget to _finalList
    _finalList.add(
      Center(
        child: Text(
          'No outputs found :(',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  } else {
    for (var i = 0; i < _utxoList.length; i++) {
      if (_utxoList[i].status.confirmed == false) {
        _finalList.add(
          PendingOutputTile(currentValue: _utxoList[i].fiatWorth),
        );
      } else {
        if (_utxoList[i].blocked == true) {
          _finalList.add(
            InactiveOutputTile(
              name: _utxoList[i].txName,
              currentValue: _utxoList[i].fiatWorth,
              fullOutput: _utxoList[i],
              blockHeight: timestampToDateString(_utxoList[i].status.blockTime),
            ),
          );
        } else {
          _finalList.add(
            ActiveOutputTile(
              name: _utxoList[i].txName,
              currentValue: _utxoList[i].fiatWorth,
              fullOutput: _utxoList[i],
              blockHeight: timestampToDateString(_utxoList[i].status.blockTime),
            ),
          );
        }
      }
    }
  }

  return _finalList;
}

String timestampToDateString(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return timeago.format(dt);
}

// class _UtxoExplanationDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('What are wallet outputs?'),
//       content: Text(
//           "Think of the outputs in your bitcoin wallet like the cash and change in your physical wallet.\n\nWe allow users who believe that they are being tracked via these outputs to conceal their identity by blocking suspicious outputs sent to their wallet.\n\nIf you believe you are not being tracked, you have no reason to worry about blocking outputs."),
//       actions: <Widget>[
//         FlatButton(
//           onPressed: () {
//             _launchDustingAttackInfo(context);
//           },
//           child: const Text('Learn more'),
//         ),
//         FlatButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('OK'),
//         ),
//       ],
//     );
//   }
// }

// void _launchDustingAttackInfo(BuildContext context) async {
//   final String url = 'https://academy.binance.com/security/what-is-a-dusting-attack';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     Toast.show('Cannot launch url', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//   }
// }
