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
    bitcoinViewTabController = TabController(
        vsync: this, length: 2, initialIndex: bitcoinViewScrollOffset.value);
    bitcoinViewScrollController = ScrollController(
        keepScrollOffset: true,
        initialScrollOffset: bitcoinViewScrollOffset.value.toDouble());
    super.initState();
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
        key: bitcoinViewScrollOffset,
        pinnedHeaderSliverHeightBuilder: () => _pinnedHeaderHeight + 50,
        controller: bitcoinViewScrollController,
        headerSliverBuilder: (BuildContext _, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Toast.show('Coming soon', context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.insert_chart),
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
          key: bitcoinViewScrollOffset,
          controller: bitcoinViewTabController,
          children: <Widget>[
            NestedScrollViewInnerScrollPositionKeyWidget(
                Key('ActivityKey'), _buildActivityView(txData)),
            NestedScrollViewInnerScrollPositionKeyWidget(
                Key('SecurityKey'), _buildSecurityView(utxoData, context)),
          ],
        ),
      ),
    );
  }

  /// Nested listViewBuilder
  Widget _buildActivityView(AsyncSnapshot<TransactionData> txData) {
    if (txData.data.txChunks.length == 0) {
      return Center(child: Text('No transactions found :('));
    } else {
      // Assuming here that #transactions >= 1
      return Container(
        child: ListView.builder(
          itemCount: txData.data.txChunks.length,
          itemBuilder: (BuildContext context, int index) {
            return StickyHeader(
              header: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
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
      return 'Transactions in-transit...';
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
      // INSERT CHECK FOR UNCONFIRMED TRANSACTION HERE FIRST

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
    finalListView.add(SizedBox(height: 13));
    return finalListView;
  }

  Widget _buildSecurityView(
      AsyncSnapshot<UtxoData> utxoData, BuildContext context) {
    return Container(
      child: ListView(
        children: _buildUtxoList(context),
      ),
    );
  }
}

List<Widget> _buildUtxoList(BuildContext context) {
  return [];
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
