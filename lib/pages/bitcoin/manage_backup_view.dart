import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/bitcoin_service.dart';

class ManageBackupView extends StatefulWidget {
  ManageBackupView({Key key}) : super(key: key);

  @override
  _ManageBackupViewState createState() => _ManageBackupViewState();
}

class _ManageBackupViewState extends State<ManageBackupView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup manager', style: GoogleFonts.rubik()),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.deepPurpleAccent,
                child: Text(
                  'A message from Paymint:\n\nA physical backup is as secure as it gets. We understand that it may be an annoying minute to write down 12 words but knowing that you have an unhackable offline backup of all your Bitcoin brings a peace of mind that no digital technology can match.\n\nIt buys you the freedom of being able to lose your phone without having to lose your Bitcoin. That is invaluable as you begin to take responsibility for your own money.\n\nWelcome to Bitcoin, you now have full control.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              height: 100,
              child: Center(
                child: CupertinoButton.filled(
                  child: Text('Reveal wallet mnemonic'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/revealmnemonic');
                  },
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.pushNamed(context, '/restorewallet');
              },
              child: Text('Restore wallet from backup',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
