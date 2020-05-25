import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:paymint/services/services.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';

class ActionsView extends StatefulWidget {
  ActionsView({Key key}) : super(key: key);

  @override
  _ActionsViewState createState() => _ActionsViewState();
}

class _ActionsViewState extends State<ActionsView>
    with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    this._controller = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: TabBar(
          controller: _controller,
          labelStyle: GoogleFonts.rubik(),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(width: 3.0, color: Colors.blue),
          ),
          tabs: <Widget>[
            Tab(
              text: 'Receive',
            ),
            Tab(
              text: 'Send',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          _ReceiveView(),
          Container(
            child: Center(
              child: Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiveView extends StatefulWidget {
  _ReceiveView({Key key}) : super(key: key);

  @override
  __ReceiveViewState createState() => __ReceiveViewState();
}

class __ReceiveViewState extends State<_ReceiveView> {
  @override
  Widget build(BuildContext context) {
    final _bitcoinService = Provider.of<BitcoinService>(context);

    return Scaffold(
      bottomNavigationBar: Container(
        height: 125,
        child: ListView(
          children: <Widget>[
            ListTile(
              onTap: () {},
              title: Text('Reveal address text'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () {},
              title: Text('Show previous addresses'),
              trailing: Icon(Icons.chevron_right),
            )
          ],
        ),
      ),
      body: FutureBuilder(
      future: _bitcoinService.currentReceivingAddress,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          print(snapshot.data);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(height: 50),
              PrettyQr(
                data: snapshot.data,
                roundEdges: true,
                elementColor: Colors.black,
                typeNumber: 4,
                size: 200,
              ),
              Container(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(text: snapshot.data));
                      Toast.show('Address copied to clipboard', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    },
                    fillColor: Colors.black,
                    elevation: 0,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                    child: Icon(Icons.content_copy, color: Colors.white, size: 20),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Share.share(snapshot.data);
                    },
                    fillColor: Colors.black,
                    elevation: 0,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                    child:
                        Icon(Icons.share, color: Colors.white, size: 20),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Toast.show('Feature coming soon', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    },
                    fillColor: Colors.grey,
                    elevation: 0,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                    child:
                        Icon(Icons.save_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    ));
  }
}

class _SendView extends StatefulWidget {
  _SendView({Key key}) : super(key: key);

  @override
  __SendViewState createState() => __SendViewState();
}

class __SendViewState extends State<_SendView> {
  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}