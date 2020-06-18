import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:animations/animations.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:paymint/services/bitcoin_service.dart';
import 'package:provider/provider.dart';

class RestoreWalletView extends StatefulWidget {
  RestoreWalletView({Key key}) : super(key: key);

  @override
  _RestoreWalletViewState createState() => _RestoreWalletViewState();
}

class _RestoreWalletViewState extends State<RestoreWalletView> {
  TextEditingController textController = new TextEditingController();
  String txCountSelection = "0-50";
  int txCountSelectionIndex = 0;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  configuration: FadeScaleTransitionConfiguration(
                      barrierDismissible: false),
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Restore wallet', style: GoogleFonts.rubik()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Input your wallet mnemonic (12 words) separated by spaces but without spaces at the start or end of the mnemonic.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            TextField(
              controller: textController,
              autofocus: true,
              showCursor: true,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Wallet mnemonic',
                isDense: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}

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
      content: Text(
          'Wallet recovery has completed. Hop in support if something doesn\'t seem right'),
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
          SizedBox(width: 8),
          Text('Please do not exit'),
        ],
      ),
      content: Text(
          "We're attempting to recover your wallet and it may take a few minutes. Please do not exit the app or leave this screen"),
    );
  }
}
