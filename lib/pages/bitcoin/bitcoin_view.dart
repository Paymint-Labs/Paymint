import 'package:flutter/cupertino.dart' hide NestedScrollView;
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:paymint/components/bitcoin_alt_views.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/services.dart';
import 'package:paymint/pages/bitcoin/actions_view.dart';
import 'package:paymint/pages/bitcoin/activity_view.dart';
import 'package:paymint/components/global_keys.dart';
import 'package:toast/toast.dart';

// FIRST REDO KEYS FOR BITCOINVIEW
// THEN LINK CORRECT KEYS FOR EXTENDEDNESTEDSCROLLVIEW
//

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
      future: wallet.utxoData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return FutureBuilder(
          future: wallet.transactionData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildMainBitcoinView(context);
            } else {
              return BitcoinViewLoading();
            }
          },
        );
      },
    );
  }

  // No need to pass future data as function parameters. Instead create provider reference object and pull directly
  // since this needs to wait for the future to finish before rendering anyway
  Scaffold buildMainBitcoinView(BuildContext context) {
    final _statusBarHeight = MediaQuery.of(context).padding.top;
    final _pinnedHeaderHeight = _statusBarHeight + kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _OpenContainerWrapper(
        transitionType: _transitionType,
        closedBuilder: (BuildContext _, VoidCallback openContainer) {
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
                title: Text("\$793.86", style: GoogleFonts.rubik()),
                centerTitle: true,
                titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: Text(
                      '0.11372974 BTC',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                key: bitcoinViewScrollOffset,
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
            NestedScrollViewInnerScrollPositionKeyWidget(Key('ActivityKey'), ActivityView()),
            NestedScrollViewInnerScrollPositionKeyWidget(Key('SecurityKey'), Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }
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
