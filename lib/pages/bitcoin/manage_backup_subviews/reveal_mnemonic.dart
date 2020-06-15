import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class RevealMnemonicView extends StatefulWidget {
  RevealMnemonicView({Key key}) : super(key: key);

  @override
  _RevealMnemonicViewState createState() => _RevealMnemonicViewState();
}

class _RevealMnemonicViewState extends State<RevealMnemonicView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Wallet mnemonic', style: GoogleFonts.rubik()),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            Text(
              'Write these words down on some sort of physical medium instead of on your Cloud drive or notes app. Preferably a piece of paper that you can hide or a notebook whose location is not easily misplaced.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                color: Colors.deepPurpleAccent,
              ),
            )
          ],
        ),
      ),
    );
  }
}
