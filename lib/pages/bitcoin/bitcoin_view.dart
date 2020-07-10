import 'package:flutter/cupertino.dart' hide NestedScrollView;
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:paymint/components/bitcoin_alt_views.dart';
import 'package:paymint/components/list_tile_components.dart';
import 'package:paymint/models/models.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/services.dart';
import 'package:paymint/pages/bitcoin/actions_view.dart';
import 'package:paymint/components/globals.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:toast/toast.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

/// BitcoinView refers to the first tab in the app's [main_view] widget.
class BitcoinView extends StatefulWidget {
  BitcoinView({Key key}) : super(key: key);

  @override
  _BitcoinViewState createState() => _BitcoinViewState();
}

class _BitcoinViewState extends State<BitcoinView>
    with TickerProviderStateMixin {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;
  double _fabDimension = 56.0;

  @override
  void initState() {
    super.initState();
    bitcoinViewTabController =
        TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<BitcoinService>(context);
    return FutureBuilder(
      future: wallet.transactionData,
      builder: (BuildContext context,
          AsyncSnapshot<TransactionData> transactionData) {
        if (transactionData.connectionState == ConnectionState.done) {
          return FutureBuilder(
              future: wallet.utxoData,
              builder:
                  (BuildContext context, AsyncSnapshot<UtxoData> utxoData) {
                if (utxoData.connectionState == ConnectionState.done) {
                  return _buildMainBitcoinView(
                      context, utxoData, transactionData);
                } else {
                  return BitcoinViewLoading();
                }
              });
        } else {
          return BitcoinViewLoading();
        }
      },
    );
  }

  Scaffold _buildMainBitcoinView(BuildContext context,
      AsyncSnapshot<UtxoData> utxoData, AsyncSnapshot<TransactionData> txData) {
    final _statusBarHeight = MediaQuery.of(context).padding.top;
    final _pinnedHeaderHeight = _statusBarHeight + kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _OpenContainerWrapper(
        transitionType: _transitionType,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return Container(
            color: Colors.lightBlue,
            height: this._fabDimension,
            width: this._fabDimension,
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
      body: NestedScrollView(
        innerScrollPositionKeyBuilder: () {
          if (bitcoinViewTabController.index == 0) {
            return PageStorageKey('ActivityKey');
          } else {
            return PageStorageKey('SecurityKey');
          }
        },
        pinnedHeaderSliverHeightBuilder: () => _pinnedHeaderHeight + 50,
        headerSliverBuilder: (BuildContext _, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed: () {
                  Toast.show('Coming soon', context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    Toast.show('Coming soon', context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  },
                )
              ],
              pinned: true,
              forceElevated: boxIsScrolled,
              expandedHeight: MediaQuery.of(context).size.width / 1.75,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(utxoData.data.totalUserCurrency,
                    style: GoogleFonts.rubik()),
                centerTitle: true,
                titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: Text(
                      utxoData.data.bitcoinBalance.toString() + ' BTC',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: bitcoinViewTabController,
                labelStyle: GoogleFonts.rubik(),
                indicatorSize: TabBarIndicatorSize
                    .label, // Adjust indicator length to label length
                indicator: UnderlineTabIndicator(
                  borderSide: const BorderSide(width: 3.0, color: Colors.blue),
                ),
                tabs: <Widget>[
                  Tab(
                    text: 'Activity',
                  ),
                  Tab(
                    text: 'Security',
                  ),
                ],
              ),
            )
          ];
        },
        body: TabBarView(
          controller: bitcoinViewTabController,
          children: <Widget>[
            NestedScrollViewInnerScrollPositionKeyWidget(
              PageStorageKey('ActivityKey'),
              NestedScrollViewRefreshIndicator(
                child: _buildActivityView(context, txData),
                onRefresh: () async {
                  final btcService = Provider.of<BitcoinService>(context);
                  await btcService.refreshWalletData();
                },
              ),
            ),
            NestedScrollViewInnerScrollPositionKeyWidget(
                PageStorageKey('SecurityKey'),
                NestedScrollViewRefreshIndicator(
                  child: _buildSecurityView(utxoData, context),
                  onRefresh: () async {
                    final btcService = Provider.of<BitcoinService>(context);
                    await btcService.refreshWalletData();
                  },
                )),
          ],
        ),
      ),
    );
  }

  /// Nested listViewBuilder
  Widget _buildActivityView(
      BuildContext context, AsyncSnapshot<TransactionData> txData) {
    if (txData.data.txChunks.length == 0) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No transactions found :(',
            textScaleFactor: 1.1,
          ),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                final btcService = Provider.of<BitcoinService>(context);
                await btcService.refreshWalletData();
              })
        ],
      ));
    } else {
      // Assuming here that #transactions >= 1
      return Container(
        child: ListView.builder(
          itemCount: txData.data.txChunks.length,
          itemBuilder: (BuildContext context, int index) {
            return StickyHeader(
              header: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(10, 8, 0, 5),
                  child: Text(
                    extractDateFromTimestamp(
                        txData.data.txChunks[index].timestamp ?? 0),
                    textScaleFactor: 1.25,
                  )),
              content: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: _buildTransactionChildLists(
                    txData.data.txChunks[index].transactions),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
              ),
            );
          },
        ),
      );
    }
  }

  String extractDateFromTimestamp(int timestamp) {
    if (timestamp == 0) {
      return 'Now...';
    }

    final int weekday =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).weekday;
    final int day = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).day;
    final int month =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).month;
    final int year = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).year;

    return monthMap[month] + ' $day, $year - ' + weekDayMap[weekday];
  }

  List<Widget> _buildTransactionChildLists(List<Transaction> txChildren) {
    final List<Widget> finalListView = [];

    final satoshisToBtc =
        (int satoshiAmount) => (satoshiAmount / 100000000).toString();

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
          // Here, we assume the transaction is a Receive type transaction
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

  Widget _buildSecurityView(
      AsyncSnapshot<UtxoData> utxoData, BuildContext context) {
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

  List<Widget> _finalList = [
    Container(
      height: 100,
      child: Center(
        child: CupertinoButton.filled(
          child: Text('Manage wallet backup', style: GoogleFonts.rubik()),
          onPressed: () {
            Navigator.pushNamed(context, '/backupmanager');
          },
        ),
      ),
    ),
    Container(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Wallet Outputs',
            textScaleFactor: 1.3,
          ),
          IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showModal<void>(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(),
                  builder: (BuildContext context) {
                    return _UtxoExplanationDialog();
                  },
                );
              })
        ],
      ),
    )
  ];

  if (_utxoList.length == 0) {
    // For modifying no utxos empty state if necessary. Add widget to _finalList
  } else {
    for (var i = 0; i < _utxoList.length; i++) {
      if (_utxoList[i].status.confirmed == false) {
        _finalList.add(PendingOutputTile(currentValue: _utxoList[i].fiatWorth));
      } else {
        if (_utxoList[i].blocked == true) {
          _finalList.add(InactiveOutputTile(
              name: _utxoList[i].txName,
              currentValue: _utxoList[i].fiatWorth,
              fullOutput: _utxoList[i],
              blockHeight:
                  timestampToDateString(_utxoList[i].status.blockTime)));
        } else {
          _finalList.add(ActiveOutputTile(
              name: _utxoList[i].txName,
              currentValue: _utxoList[i].fiatWorth,
              fullOutput: _utxoList[i],
              blockHeight:
                  timestampToDateString(_utxoList[i].status.blockTime)));
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

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    this.closedBuilder,
    this.transitionType,
  });

  final OpenContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 6.0,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        ),
      ),
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return ActionsView();
      },
      tappable: true,
      closedBuilder: closedBuilder,
    );
  }
}

class _UtxoExplanationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('What are wallet outputs?'),
      content: Text(
          "Think of the outputs in your bitcoin wallet like the cash and change in your physical wallet.\n\nWe allow users who believe that they are being tracked via these outputs to conceal their identity by blocking suspicious outputs sent to their wallet.\n\nIf you believe you are not being tracked, you have no reason to worry about blocking outputs."),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _launchDustingAttackInfo(context);
          },
          child: const Text('Learn more'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

void _launchDustingAttackInfo(BuildContext context) async {
  final String url = 'https://academy.binance.com/security/what-is-a-dusting-attack';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}