import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/activity_list_tiles.dart';

class ActivityView extends StatefulWidget {
  ActivityView({Key key}) : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Container(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                child: Text(
                  '23 Dec, 2019 - Monday',
                  style: GoogleFonts.rubik(),
                  textScaleFactor: 1.25,
                ),
              ),
            ),
            SendListTile(
              amount: '0.11956382',
              currentValue: '749.80',
              previousValue: '110.92',
            ),
            ReceiveListTile(
              amount: '0.02163382',
              currentValue: '149.11',
              previousValue: '71.92',
            ),
            Container(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                child: Text(
                  '23 Dec, 2019 - Tuesday',
                  style: GoogleFonts.rubik(),
                  textScaleFactor: 1.25,
                ),
              ),
            ),
            ReceiveListTile(
              amount: '0.02163382',
              currentValue: '149.11',
              previousValue: '71.92',
            ),
          ],
        ));
  }
}
