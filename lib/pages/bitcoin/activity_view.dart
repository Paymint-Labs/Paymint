import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      child: Center(
          child: ListView(
        addSemanticIndexes: true,
        children: <Widget>[
          ListTile(
            onTap: () {
              print('object');
            },
            enabled: true,
            leading:
                Icon(Icons.keyboard_arrow_up, color: Colors.pink, size: 40),
            title: Text(
              'Sent',
              style: GoogleFonts.rubik(),
            ),
            subtitle: Text(
              '0.01246385 BTC',
              style: GoogleFonts.rubik(),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('\$51.66 now', style: GoogleFonts.rubik()),
                Text(
                  '\$50.23 when sent',
                  style: GoogleFonts.rubik(),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {},
            enabled: true,
            leading:
                Icon(Icons.keyboard_arrow_up, color: Colors.pink, size: 40),
            title: Text(
              'Sent',
              style: GoogleFonts.rubik(),
            ),
            subtitle: Text(
              '0.01246385 BTC',
              style: GoogleFonts.rubik(),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('\$51.66 now', style: GoogleFonts.rubik()),
                Text(
                  '\$50.23 when sent',
                  style: GoogleFonts.rubik(),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {},
            enabled: true,
            leading: Icon(Icons.keyboard_arrow_down,
                color: Colors.blueAccent, size: 40),
            title: Text(
              'Received',
              style: GoogleFonts.rubik(),
            ),
            subtitle: Text(
              '0.65440143 BTC',
              style: GoogleFonts.rubik(),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('\$1,131.00 now', style: GoogleFonts.rubik()),
                Text(
                  '\$1,226.23 when received',
                  style: GoogleFonts.rubik(),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
