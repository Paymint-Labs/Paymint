import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

class BroadcastRawHexView extends StatefulWidget {
  @override
  _BroadcastRawHexViewState createState() => _BroadcastRawHexViewState();
}

class _BroadcastRawHexViewState extends State<BroadcastRawHexView> {
  TextEditingController textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        backgroundColor: Color(0xff121212),
        title: Text('Broadcast raw hex', style: GoogleFonts.rubik(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.cyanAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: CupertinoButton.filled(
            child: Text('Broadcast'),
            onPressed: () async => broadcastTx(textController.text),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Input the raw transaction hex you wish to broadcast to the Bitcoin network, below.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            TextField(
              controller: textController,
              autofocus: true,
              showCursor: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                labelText: 'Raw hex',
              ),
            )
          ],
        ),
      ),
    );
  }

  broadcastTx(String hex) async {
    if (textController.text.trim() == '' || textController.text.isEmpty) {
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return EmptyTextDialog();
        },
      );
      return 0;
    }

    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    final res = await bitcoinService.submitHexToNetwork(hex);

    showModal(
      context: context,
      configuration: FadeScaleTransitionConfiguration(),
      builder: (BuildContext context) {
        return LoadingDialog();
      },
    );

    Navigator.pop(context);
    if (res) {
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _TransactionSuccessDialog();
        },
      );
    } else {
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _TransactionFailureDialog();
        },
      );
    }
  }
}

class _TransactionSuccessDialog extends StatelessWidget {
  const _TransactionSuccessDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transaction successful!', style: TextStyle(color: Colors.white)),
      content: Container(
        height: 80,
        child: Center(child: Icon(Icons.check_circle, color: Colors.green, size: 70)),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}

class _TransactionFailureDialog extends StatelessWidget {
  const _TransactionFailureDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        'Transaction unsuccessful!',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        'Please try again',
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}

class EmptyTextDialog extends StatelessWidget {
  const EmptyTextDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        'Textfield is empty',
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 12),
          Text(
            'Sending to network...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Text(
        'Please be patient',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
