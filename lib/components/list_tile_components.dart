/// ListTile components for the Activity and Security Views inside the BitcoinView widget

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:paymint/components/animated_gradient.dart';
import 'package:paymint/models/models.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveOutputTile extends StatefulWidget {
  final String name;
  final String currentValue;
  final String blockHeight;

  ActiveOutputTile(
      {Key key,
      @required this.name,
      @required this.currentValue,
      @required this.blockHeight})
      : super(key: key);

  @override
  _ActiveOutputTileState createState() =>
      _ActiveOutputTileState(name, currentValue, blockHeight);
}

class _ActiveOutputTileState extends State<ActiveOutputTile> {
  final String _name;
  final String _currentValue;
  final String _blockHeight;

  final List<Gradient> _sweepGradients = [
    SweepGradient(colors: [Colors.blueAccent, Colors.blue, Colors.blueAccent]),
    SweepGradient(
        colors: [Colors.cyanAccent, Colors.lightBlueAccent, Colors.cyanAccent]),
  ];

  _ActiveOutputTileState(this._name, this._currentValue, this._blockHeight);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_name),
      subtitle: Text(_blockHeight),
      trailing: Text(_currentValue),
      leading: CircleAvatar(
        child: ClipRRect(
          child: AnimatedGradientBox(_sweepGradients, Curves.bounceInOut),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onTap: () {},
    );
  }
}

class PendingOutputTile extends StatefulWidget {
  final String currentValue;

  PendingOutputTile(
      {Key key,
      @required this.currentValue})
      : super(key: key);
  
  @override
  _PendingOutputTileState createState() => _PendingOutputTileState(currentValue);
}

class _PendingOutputTileState extends State<PendingOutputTile> {
  final String _currentValue;

  final List<Gradient> _sweepGradients = [
    SweepGradient(colors: [Colors.purple, Colors.purpleAccent, Colors.purple]),
    SweepGradient(colors: [
      Colors.deepPurple,
      Colors.deepPurpleAccent,
      Colors.deepPurple
    ]),
  ];

  _PendingOutputTileState(this._currentValue);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Pending output...'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            _currentValue,
          ),
          Text(
            'Pending', style: TextStyle(color: Colors.purple),
          )
        ],
      ),
      leading: CircleAvatar(
        child: ClipRRect(
          child: AnimatedGradientBox(_sweepGradients, Curves.bounceInOut),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onTap: () {},
    );
  }
  }

class InactiveOutputTile extends StatefulWidget {
  final String name;
  final String currentValue;
  final String blockHeight;

  InactiveOutputTile(
      {Key key,
      @required this.name,
      @required this.currentValue,
      @required this.blockHeight})
      : super(key: key);

  @override
  _InactiveOutputTileState createState() =>
      _InactiveOutputTileState(name, currentValue, blockHeight);
}

class _InactiveOutputTileState extends State<InactiveOutputTile> {
  final String _name;
  final String _currentValue;
  final String _blockHeight;

  final List<Gradient> _sweepGradients = [
    SweepGradient(colors: [Colors.purple, Colors.purpleAccent, Colors.purple]),
    SweepGradient(colors: [
      Colors.deepPurple,
      Colors.deepPurpleAccent,
      Colors.deepPurple
    ]),
  ];

  _InactiveOutputTileState(this._name, this._currentValue, this._blockHeight);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_name),
      subtitle: Text(_blockHeight),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            _currentValue,
          ),
          Text(
            'BLOCKED', style: TextStyle(color: Colors.red),
          )
        ],
      ),
      leading: CircleAvatar(
        child: ClipRRect(
          child: AnimatedGradientBox(_sweepGradients, Curves.bounceInOut),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onTap: () {},
    );
  }
}

class IncomingTransactionListTile extends StatefulWidget {
  IncomingTransactionListTile(this.satoshiAmt, this.currentValue);
  final String satoshiAmt;
  final String currentValue;

  @override
  _IncomingTransactionListTileState createState() =>
      _IncomingTransactionListTileState();
}

class _IncomingTransactionListTileState
    extends State<IncomingTransactionListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Incoming Transaction...'),
      subtitle: Text(widget.satoshiAmt),
      trailing: Text(widget.currentValue),
      onTap: () {},
    );
  }
}

class OutgoingTransactionListTile extends StatefulWidget {
  OutgoingTransactionListTile(this.satoshiAmt, this.currentValue);
  final String satoshiAmt;
  final String currentValue;

  @override
  _OutgoingTransactionListTileState createState() =>
      _OutgoingTransactionListTileState();
}

class _OutgoingTransactionListTileState
    extends State<OutgoingTransactionListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Outgoing Transaction...'),
      subtitle: Text(widget.satoshiAmt),
      trailing: Text(widget.currentValue),
      onTap: () {},
    );
  }
}

class SendListTile extends StatefulWidget {
  SendListTile(
      {Key key, this.amount, this.currentValue, this.previousValue, this.tx})
      : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  final Transaction tx;

  @override
  _SendListTileState createState() => _SendListTileState();
}

class _SendListTileState extends State<SendListTile> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: this._transitionType,
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        return _SendDetailsPage(widget.tx);
      },
      tappable: true,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: Icon(Icons.keyboard_arrow_up, color: Colors.pink, size: 40),
          title: Text(
            'Sent',
          ),
          subtitle: Text(
            widget.amount + ' BTC',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.currentValue + ' now',
              ),
              Text(
                widget.previousValue + ' when sent',
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReceiveListTile extends StatefulWidget {
  const ReceiveListTile(
      {Key key, this.amount, this.currentValue, this.previousValue, this.tx})
      : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  final Transaction tx;

  @override
  _ReceiveListTileState createState() => _ReceiveListTileState();
}

class _ReceiveListTileState extends State<ReceiveListTile> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: this._transitionType,
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        return _ReceiveDetailsPage(widget.tx);
      },
      tappable: true,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: Icon(Icons.keyboard_arrow_down,
              color: Colors.blueAccent, size: 40),
          title: Text(
            'Received',
          ),
          subtitle: Text(
            widget.amount + ' BTC',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.currentValue + ' now',
              ),
              Text(
                widget.previousValue + ' when received',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PurchaseListTile extends StatelessWidget {
  const PurchaseListTile(
      {Key key, this.purchaseAmount, this.valueAtTimeOfPurchase})
      : super(key: key);

  final String purchaseAmount; // Denominated in BTC
  final String
      valueAtTimeOfPurchase; // USD value of purchaseAmount at the time of the purchase

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Icon(
        Icons.show_chart,
        color: Colors.black,
        size: 30,
      ),
      title: Text(
        'Purchased ',
      ),
      subtitle: Text(
        purchaseAmount + ' BTC',
      ),
      trailing: Text(
        '\$' + valueAtTimeOfPurchase + ' when bought',
      ),
    );
  }
}

class _SendDetailsPage extends StatefulWidget {
  final Transaction _tx;

  _SendDetailsPage(this._tx);
  @override
  __SendDetailsPageState createState() => __SendDetailsPageState();
}

class __SendDetailsPageState extends State<_SendDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transaction details',
            style: GoogleFonts.rubik(
              textStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 10,
        ),
        body: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.width / 2,
                color: Colors.black,
                child: Center(
                    child: FlareActor('assets/rive/success.flr',
                        animation: 'Untitled'))),
            ListTile(
              title: Text('Date/Time:'),
              trailing: Text(_buildDateTimeForTx(widget._tx.timestamp)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Action:'),
              trailing: Text(widget._tx.txType),
              onTap: () {},
            ),
            ListTile(
              title: Text('Amount:'),
              trailing: Text(_extractBtcFromSatoshis(widget._tx.amount)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth now:'),
              trailing: Text(widget._tx.worthNow),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth when sent:'),
              trailing: Text(widget._tx.worthAtBlockTimestamp),
              onTap: () {},
            ),
            ListTile(
              title: Text('Fee paid:'),
              trailing: Text(widget._tx.fees.toString() + ' sats'),
              onTap: () {},
            ),
            ListTile(
                title: Text('Copy transaction ID',
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Clipboard.setData(new ClipboardData(text: widget._tx.txid));
                  Toast.show('ID copied to clipboard', context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                }),
            ListTile(
              title: Text('Verify on blockchain',
                  style: TextStyle(color: Colors.blue)),
              onTap: () {
                _launchTransactionUrl(context, widget._tx.txid);
              },
            )
          ],
        ));
  }
}

class _ReceiveDetailsPage extends StatefulWidget {
  final Transaction _tx;

  _ReceiveDetailsPage(this._tx);
  @override
  __ReceiveDetailsPageState createState() => __ReceiveDetailsPageState();
}

class __ReceiveDetailsPageState extends State<_ReceiveDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transaction details',
            style: GoogleFonts.rubik(
              textStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 10,
        ),
        body: ListView(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.width / 2,
                color: Colors.black,
                child: Center(
                    child: FlareActor('assets/rive/success.flr',
                        animation: 'Untitled'))),
            ListTile(
              title: Text('Date/Time:'),
              trailing: Text(_buildDateTimeForTx(widget._tx.timestamp)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Action:'),
              trailing: Text(widget._tx.txType),
              onTap: () {},
            ),
            ListTile(
              title: Text('Amount:'),
              trailing: Text(_extractBtcFromSatoshis(widget._tx.amount)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth now:'),
              trailing: Text(widget._tx.worthNow),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth when received:'),
              trailing: Text(widget._tx.worthAtBlockTimestamp),
              onTap: () {},
            ),
            ListTile(
              title: Text('Fee paid:'),
              trailing: Text(widget._tx.fees.toString() + ' sats'),
              onTap: () {},
            ),
            ListTile(
                title: Text('Copy transaction ID',
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Clipboard.setData(new ClipboardData(text: widget._tx.txid));
                  Toast.show('ID copied to clipboard', context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                }),
            ListTile(
              title: Text('Verify on blockchain',
                  style: TextStyle(color: Colors.blue)),
              onTap: () {
                _launchTransactionUrl(context, widget._tx.txid);
              },
            )
          ],
        ));
  }
}

String _buildDateTimeForTx(int timestamp) {
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return time.toLocal().toString().substring(0, 16);
}

String _extractBtcFromSatoshis(int satoshis) {
  return (satoshis / 100000000).toString() + ' BTC';
}

void _launchTransactionUrl(BuildContext context, String txid) async {
  final String url = 'https://blockstream.info/tx/' + txid;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Toast.show('Cannot launch url', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
