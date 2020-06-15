import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyBackupView extends StatefulWidget {
  VerifyBackupView({Key key}) : super(key: key);

  @override
  _VerifyBackupViewState createState() => _VerifyBackupViewState();
}

class _VerifyBackupViewState extends State<VerifyBackupView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Verify mnemonic',
            style: GoogleFonts.rubik(),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(child: Text('Verify partial', style: GoogleFonts.rubik())),
              Tab(child: Text('Verify whole', style: GoogleFonts.rubik()))
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(color: Colors.redAccent,),
            Container(color: Colors.blueAccent,)
          ],
        ),
      ),
    );
  }
}
