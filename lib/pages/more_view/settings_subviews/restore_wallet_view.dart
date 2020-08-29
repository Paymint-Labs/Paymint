import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:paymint/services/services.dart';
import 'package:flutter/cupertino.dart';

class RestoreWalletView extends StatefulWidget {
  @override
  _RestoreWalletViewState createState() => _RestoreWalletViewState();
}

class _RestoreWalletViewState extends State<RestoreWalletView> {
  TextEditingController textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: CupertinoButton.filled(
            onPressed: () async {
              if (bip39.validateMnemonic(textController.text.trim()) == false) {
                showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(),
                  builder: (BuildContext context) {
                    return InvalidInputDialog();
                  },
                );
              } else {
                final btcService = Provider.of<BitcoinService>(context);
                showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
                  builder: (BuildContext context) {
                    return WaitDialog();
                  },
                );
                await btcService.recoverWalletFromBIP32SeedPhrase(textController.text);
                await btcService.refreshWalletData();
                Navigator.pop(context);
                showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(),
                  builder: (BuildContext context) {
                    return RecoveryCompleteDialog();
                  },
                );
              }
            },
            child: Text('Recover wallet'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Input your backup\'s secret words (12 words) separated by spaces.',
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
                labelText: 'Secret Words',
                isDense: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Dialog Widgets

class InvalidInputDialog extends StatelessWidget {
  const InvalidInputDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Invalid input'),
      content: Text('Please input a valid 12-word mnemonic and try again'),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

class RecoveryCompleteDialog extends StatelessWidget {
  const RecoveryCompleteDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Recovery complete'),
      content: Text('Wallet recovery has completed. Hop in support if something doesn\'t seem right'),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

class WaitDialog extends StatelessWidget {
  const WaitDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Please do not exit'),
        ],
      ),
      content: Text(
          "We're attempting to recover your wallet and it may take a few minutes. Please do not exit the app or leave this screen"),
    );
  }
}
