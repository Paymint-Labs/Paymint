import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:paymint/models/models.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter/cupertino.dart';

class ActiveOutputTile extends StatefulWidget {
  final String name;
  final String currentValue;
  final String blockHeight;
  final UtxoObject fullOutput;

  ActiveOutputTile(
      {Key key,
      @required this.name,
      @required this.currentValue,
      @required this.blockHeight,
      @required this.fullOutput})
      : super(key: key);

  @override
  _ActiveOutputTileState createState() => _ActiveOutputTileState(name, currentValue, blockHeight, fullOutput);
}

class _ActiveOutputTileState extends State<ActiveOutputTile> {
  final String _name;
  final String _currentValue;
  final String _blockHeight;
  final UtxoObject _fullOutput;

  _ActiveOutputTileState(this._name, this._currentValue, this._blockHeight, this._fullOutput);

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      textColor: Colors.white,
      child: Container(
        color: Color(0xff121212),
        child: ListTile(
          title: Text(_name),
          subtitle: Text(_blockHeight),
          trailing: Text(
            _currentValue,
            style: TextStyle(color: Colors.white),
          ),
          leading: Icon(Icons.all_out, color: Colors.cyanAccent),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => UtxoDetailView(output: _fullOutput),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PendingOutputTile extends StatefulWidget {
  final String currentValue;

  PendingOutputTile({Key key, @required this.currentValue}) : super(key: key);

  @override
  _PendingOutputTileState createState() => _PendingOutputTileState(currentValue);
}

class _PendingOutputTileState extends State<PendingOutputTile> {
  final String _currentValue;

  _PendingOutputTileState(this._currentValue);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff121212),
      child: ListTile(
        title: Text('Pending output...', style: TextStyle(color: Colors.white)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(_currentValue, style: TextStyle(color: Colors.white)),
            Text(
              'Pending',
              style: TextStyle(color: Colors.pinkAccent),
            )
          ],
        ),
        leading: Icon(Icons.all_out, color: Colors.pinkAccent),
        onTap: () {},
      ),
    );
  }
}

class InactiveOutputTile extends StatefulWidget {
  final String name;
  final String currentValue;
  final String blockHeight;
  final UtxoObject fullOutput;

  InactiveOutputTile(
      {Key key,
      @required this.name,
      @required this.currentValue,
      @required this.blockHeight,
      @required this.fullOutput})
      : super(key: key);

  @override
  _InactiveOutputTileState createState() => _InactiveOutputTileState(name, currentValue, blockHeight, fullOutput);
}

class _InactiveOutputTileState extends State<InactiveOutputTile> {
  final String _name;
  final String _currentValue;
  final String _blockHeight;
  final UtxoObject _fullOutput;

  ContainerTransitionType containerTransitionType = ContainerTransitionType.fadeThrough;

  _InactiveOutputTileState(this._name, this._currentValue, this._blockHeight, this._fullOutput);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Color(0xff121212)),
      child: ListTile(
        title: Text(
          _name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          _blockHeight,
          style: TextStyle(color: Colors.white),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              _currentValue,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Blocked',
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
        leading: Icon(Icons.all_out, color: Colors.pink),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => UtxoDetailView(output: _fullOutput),
            ),
          );
        },
      ),
    );
  }
}

class IncomingTransactionListTile extends StatefulWidget {
  IncomingTransactionListTile(this.satoshiAmt, this.currentValue);
  final String satoshiAmt;
  final String currentValue;

  @override
  _IncomingTransactionListTileState createState() => _IncomingTransactionListTileState();
}

class _IncomingTransactionListTileState extends State<IncomingTransactionListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Incoming Transaction...', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        formatSatoshiBalance(int.parse(widget.satoshiAmt)),
        style: TextStyle(color: Colors.white),
      ),
      trailing: Text(widget.currentValue, style: TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}

class OutgoingTransactionListTile extends StatefulWidget {
  OutgoingTransactionListTile(this.satoshiAmt, this.currentValue);
  final String satoshiAmt;
  final String currentValue;

  @override
  _OutgoingTransactionListTileState createState() => _OutgoingTransactionListTileState();
}

class _OutgoingTransactionListTileState extends State<OutgoingTransactionListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Outgoing Transaction...', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        formatSatoshiBalance(int.parse(widget.satoshiAmt)),
        style: TextStyle(color: Colors.white),
      ),
      trailing: Text(widget.currentValue, style: TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}

class UtxoDetailView extends StatefulWidget {
  final UtxoObject output;

  UtxoDetailView({Key key, @required this.output}) : super(key: key);

  @override
  _UtxoDetailViewState createState() => _UtxoDetailViewState(output);
}

class _UtxoDetailViewState extends State<UtxoDetailView> {
  final UtxoObject _utxoObj;

  _UtxoDetailViewState(this._utxoObj);

  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
    UtxoObject _utxoObject;
    for (var i = 0; i < bitcoinService.allOutputs.length; i++) {
      if (bitcoinService.allOutputs[i].txid == _utxoObj.txid) {
        _utxoObject = bitcoinService.allOutputs[i];
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff121212),
        title: Text(_utxoObject.txName + ' Details', style: GoogleFonts.rubik(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Color(0xff81D4FA),
        ),
      ),
      body: Container(
        color: Color(0xff121212),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                'Transaction ID:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                shortenTxid(_utxoObject.txid),
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Date & Time:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _buildDateTimeForTx(_utxoObject.status.blockTime),
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Status:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: buildStatusTileTrailingWidget(_utxoObject.blocked),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Current Worth:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _utxoObject.fiatWorth,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Amount (in BTC):',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                (_utxoObject.value / 100000000).toString() + ' BTC',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Amount (in Sats):',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _utxoObject.value.toString() + ' Sats',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Output Index:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                'Output #' + (_utxoObject.vout + 1).toString() + ' in Transaction',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text('Copy Transaction ID', style: TextStyle(color: Colors.cyanAccent)),
              onTap: () {
                Clipboard.setData(new ClipboardData(text: _utxoObject.txid));
                Toast.show('ID copied to clipboard', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              },
            ),
            ListTile(
              title: Text('Rename Output', style: TextStyle(color: Colors.cyanAccent)),
              onTap: () {
                showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(),
                  builder: (BuildContext context) {
                    return _RenameOutputDialog(_utxoObject.txid);
                  },
                );
              },
            ),
            ListTile(
              title: buildBlockButtonForOutput(_utxoObject.blocked),
              onTap: () async {
                if (_utxoObject.blocked == true) {
                  final service = Provider.of<BitcoinService>(context);
                  service.unblockOutput(_utxoObject.txid);
                  final wallet = await Hive.openBox('wallet');
                  final blockedList = await wallet.get('blocked_tx_hashes');
                  final List blockedCopyWithoutTxid = new List();
                  for (var i = 0; i < blockedList.length; i++) {
                    if (blockedList[i] != _utxoObject.txid) {
                      blockedCopyWithoutTxid.add(blockedList[i]);
                    }
                  }
                  await wallet.put('blocked_tx_hashes', blockedCopyWithoutTxid);
                } else {
                  final service = Provider.of<BitcoinService>(context);
                  service.blockOutput(_utxoObject.txid);
                  final wallet = await Hive.openBox('wallet');
                  final blockedList = await wallet.get('blocked_tx_hashes');
                  final blockedCopy = new List();
                  for (var i = 0; i < blockedList.length; i++) {
                    blockedCopy.add(blockedList[i]);
                  }
                  blockedCopy.add(_utxoObject.txid);
                  await wallet.put('blocked_tx_hashes', blockedCopy);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _RenameOutputDialog extends StatelessWidget {
  final String txid;
  TextEditingController textEditingController = new TextEditingController();

  _RenameOutputDialog(this.txid);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text('Rename output', style: TextStyle(color: Colors.white)),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'OK',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          onPressed: () async {
            if (textEditingController.text.isEmpty) {
              Navigator.pop(context);
            }

            final labels = await Hive.openBox('labels');
            await labels.put(txid, textEditingController.text);
            final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
            bitcoinService.renameOutput(txid, textEditingController.text);
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
      content: Container(
        height: 150,
        child: Column(
          children: [
            SizedBox(height: 16),
            Center(
              child: TextField(
                autofocus: true,
                controller: textEditingController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Ouput Name'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You will need to restart the app to see the effect take place',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

String shortenTxid(String txid) {
  return txid.substring(0, 4) + '...' + txid.substring(txid.length - 4);
}

Text buildStatusTileTrailingWidget(bool blockStatus) {
  if (blockStatus == true) {
    return Text('BLOCKED', style: TextStyle(color: Colors.red));
  } else {
    return Text('Active', style: TextStyle(color: Colors.green));
  }
}

Text buildBlockButtonForOutput(bool blockStatus) {
  if (blockStatus == true) {
    return Text('Activate output', style: TextStyle(color: Colors.cyanAccent));
  } else {
    return Text('Block output', style: TextStyle(color: Colors.cyanAccent));
  }
}

class SendListTile extends StatefulWidget {
  SendListTile({Key key, this.amount, this.currentValue, this.previousValue, this.tx}) : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  final Transaction tx;

  @override
  _SendListTileState createState() => _SendListTileState();
}

class _SendListTileState extends State<SendListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff121212),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext _) => _SendDetailsPage(widget.tx),
          ),
        ),
        leading: Icon(
          Icons.keyboard_arrow_up,
          color: Colors.pinkAccent,
          size: 40,
        ),
        title: Text(
          'Sent',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          formatSatoshiBalance(widget.tx.amount),
          style: TextStyle(color: Colors.white),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              widget.currentValue + ' now',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              widget.previousValue + ' when sent',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiveListTile extends StatefulWidget {
  const ReceiveListTile({Key key, this.amount, this.currentValue, this.previousValue, this.tx}) : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  final Transaction tx;

  @override
  _ReceiveListTileState createState() => _ReceiveListTileState();
}

class _ReceiveListTileState extends State<ReceiveListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Color(0xff121212)),
      child: ListTile(
        onTap: () =>
            Navigator.push(context, CupertinoPageRoute(builder: (BuildContext _) => _ReceiveDetailsPage(widget.tx))),
        leading: Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent, size: 40),
        title: Text(
          'Received',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          formatSatoshiBalance(widget.tx.amount),
          style: TextStyle(color: Colors.white),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              widget.currentValue + ' now',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              widget.previousValue + ' when received',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

String formatSatoshiBalance(int satoshiBalance) {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  return satoshiBalance.toString().replaceAllMapped(reg, mathFunc) + ' sats';
}

class PurchaseListTile extends StatelessWidget {
  const PurchaseListTile({Key key, this.purchaseAmount, this.valueAtTimeOfPurchase}) : super(key: key);

  final String purchaseAmount; // Denominated in BTC
  final String valueAtTimeOfPurchase; // USD value of purchaseAmount at the time of the purchase

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
  int viewDenomination;

  @override
  void initState() {
    this.viewDenomination = 0; // 0 == Satoshis & 1 == BTC denomination
    super.initState();
  }

  buildAmount() {
    if (viewDenomination == 0) {
      return formatSatoshiBalance(widget._tx.amount);
    } else if (viewDenomination == 1) {
      return (widget._tx.amount / 100000000).toString() + ' BTC';
    }
  }

  buildFeeAmount() {
    if (viewDenomination == 0) {
      return formatSatoshiBalance(widget._tx.fees);
    } else if (viewDenomination == 1) {
      return (widget._tx.fees / 100000000).toString() + ' BTC';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff81D4FA),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction details',
          style: GoogleFonts.rubik(
            textStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        backgroundColor: Color(0xff121212),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xff121212),
        child: ListView(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.width / 2,
                color: Color(0xff121212),
                child: Center(child: FlareActor('assets/rive/success.flr', animation: 'Untitled'))),
            ListTile(
              title: Text(
                'Date & Time:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _buildDateTimeForTx(widget._tx.timestamp),
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Action:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                widget._tx.txType,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Amount:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                buildAmount(),
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  if (viewDenomination == 0) {
                    viewDenomination = 1;
                  } else if (viewDenomination == 1) {
                    viewDenomination = 0;
                  }
                });
              },
            ),
            ListTile(
              title: Text(
                'Worth now:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                widget._tx.worthNow,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Worth when sent:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                widget._tx.worthAtBlockTimestamp,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Text(
                'Fee paid:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                buildFeeAmount(),
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  if (viewDenomination == 0) {
                    viewDenomination = 1;
                  } else if (viewDenomination == 1) {
                    viewDenomination = 0;
                  }
                });
              },
            ),
            ListTile(
                title: Text('Copy transaction ID', style: TextStyle(color: Colors.cyanAccent)),
                onTap: () {
                  Clipboard.setData(new ClipboardData(text: widget._tx.txid));
                  Toast.show('ID copied to clipboard', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                }),
            ListTile(
              title: Text('Verify on blockchain', style: TextStyle(color: Colors.cyanAccent)),
              onTap: () {
                _launchTransactionUrl(context, widget._tx.txid);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _ReceiveDetailsPage extends StatefulWidget {
  final Transaction _tx;

  _ReceiveDetailsPage(this._tx);
  @override
  __ReceiveDetailsPageState createState() => __ReceiveDetailsPageState();
}

class __ReceiveDetailsPageState extends State<_ReceiveDetailsPage> {
  int viewDenomination;

  @override
  void initState() {
    this.viewDenomination = 0;
    super.initState();
  }

  buildAmount() {
    if (viewDenomination == 0) {
      return formatSatoshiBalance(widget._tx.amount);
    } else if (viewDenomination == 1) {
      return (widget._tx.amount / 100000000).toString() + ' BTC';
    }
  }

  buildFeeAmount() {
    if (viewDenomination == 0) {
      return formatSatoshiBalance(widget._tx.fees);
    } else if (viewDenomination == 1) {
      return (widget._tx.fees / 100000000).toString() + ' BTC';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Color(0xff81D4FA),
        ),
        title: Text(
          'Transaction details',
          style: GoogleFonts.rubik(
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Color(0xff121212),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xff121212),
        child: ListView(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.width / 2,
                color: Color(0xff121212),
                child: Center(
                  child: FlareActor('assets/rive/success.flr', animation: 'Untitled'),
                )),
            ListTile(
              title: Text(
                'Date & Time:',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(_buildDateTimeForTx(widget._tx.timestamp), style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Action:', style: TextStyle(color: Colors.white)),
              trailing: Text(widget._tx.txType, style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Amount:', style: TextStyle(color: Colors.white)),
              trailing: Text(buildAmount(), style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  if (viewDenomination == 0) {
                    viewDenomination = 1;
                  } else if (viewDenomination == 1) {
                    viewDenomination = 0;
                  }
                });
              },
            ),
            ListTile(
              title: Text('Worth now:', style: TextStyle(color: Colors.white)),
              trailing: Text(widget._tx.worthNow, style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth when received:', style: TextStyle(color: Colors.white)),
              trailing: Text(widget._tx.worthAtBlockTimestamp, style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Fee paid:', style: TextStyle(color: Colors.white)),
              trailing: Text(buildFeeAmount(), style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  if (viewDenomination == 0) {
                    viewDenomination = 1;
                  } else if (viewDenomination == 1) {
                    viewDenomination = 0;
                  }
                });
              },
            ),
            ListTile(
              title: Text(
                'Copy transaction ID',
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onTap: () {
                Clipboard.setData(new ClipboardData(text: widget._tx.txid));
                Toast.show('ID copied to clipboard', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              },
            ),
            ListTile(
              title: Text(
                'Verify on blockchain',
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onTap: () {
                _launchTransactionUrl(context, widget._tx.txid);
              },
            )
          ],
        ),
      ),
    );
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
    Toast.show('Cannot launch url', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
