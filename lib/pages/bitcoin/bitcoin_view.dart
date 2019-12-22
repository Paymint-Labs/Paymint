import 'package:flutter/material.dart';

class BitcoinView extends StatefulWidget {
  BitcoinView({Key key}) : super(key: key);

  @override
  _BitcoinViewState createState() => _BitcoinViewState();
}

class _BitcoinViewState extends State<BitcoinView> with TickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController;

  @override
  void initState() {
    this._tabController = TabController(vsync: this, length: 2);
    this._scrollController = ScrollController(keepScrollOffset: true);
    super.initState();
  }

  @override
  void dispose() {
    this._tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext _, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              pinned: true,
              forceElevated: boxIsScrolled,
              expandedHeight: 220,
              flexibleSpace: FlexibleSpaceBar(
                title: Text("\$3,792.11"),
                centerTitle: true,
                titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 60),
              ),
              bottom: TabBar(
                indicator: UnderlineTabIndicator(
                    insets: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    borderSide: const BorderSide(width: 3.0, color: Colors.blue),
                ),
                controller: _tabController,
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
        body: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Container(color: Colors.white,),
              Container(color: Colors.redAccent,),
            ],
          ),
        ),
      ),
    );
  }
}
