import 'package:flutter/material.dart';
import 'package:paymint/components/globals.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget displayed in place of BitcoinView while fetching data from API
class BitcoinViewLoading extends StatefulWidget {
  BitcoinViewLoading({Key key}) : super(key: key);

  @override
  _BitcoinViewLoadingState createState() => _BitcoinViewLoadingState();
}

class _BitcoinViewLoadingState extends State<BitcoinViewLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        key: bitcoinViewScrollOffset,
        headerSliverBuilder: (BuildContext _, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              pinned: true,
              forceElevated: boxIsScrolled,
              expandedHeight: MediaQuery.of(context).size.width / 1.75,
              flexibleSpace: FlexibleSpaceBar(
                title: Shimmer.fromColors(
                  period: Duration(milliseconds: 850),
                  baseColor: Colors.white12,
                  highlightColor: Colors.white60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      height: 20,
                      width: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
                centerTitle: true,
                titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: Shimmer.fromColors(
                      period: Duration(milliseconds: 850),
                      baseColor: Colors.white12,
                      highlightColor: Colors.white60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          height: 20,
                          width: 200,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                key: bitcoinViewScrollOffset,
                controller: bitcoinViewTabController,
                labelStyle: GoogleFonts.rubik(),
                indicatorSize: TabBarIndicatorSize.label,
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
          physics: NeverScrollableScrollPhysics(),
          key: bitcoinViewScrollOffset,
          controller: bitcoinViewTabController,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 16),
                ListTile(
                  leading: Shimmer.fromColors(
                    period: Duration(milliseconds: 800),
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        height: 20,
                        width: 180,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  period: Duration(milliseconds: 850),
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: ListTile(
                    leading: CircleAvatar(),
                    title: Text('Received'),
                    subtitle: Text('0.000238 BTC'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('\$48.26 now'),
                        Text('\$43.91 when received'),
                      ],
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  period: Duration(milliseconds: 850),
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: ListTile(
                    leading: CircleAvatar(),
                    title: Text('Sent'),
                    subtitle: Text('0.0001 BTC'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('\$3.24 now'),
                        Text('\$8.91 when sent'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
