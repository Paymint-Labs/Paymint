import 'package:flutter/cupertino.dart';
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
          child: ListView(
        children: <Widget>[
          Container(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Container(
              child: Text('25 Dec, 2019 - Wednesday', style: GoogleFonts.rubik(), textScaleFactor: 1.25,),
            ),
          ),
          ListTile(
            onTap: () {
              print('object');
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) => EmptyWidget()));
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
            onTap: () { CupertinoPageRoute(
              builder: (_) {
                return Container(color: Colors.white,);
              },
              fullscreenDialog: false,
              maintainState: true
            ); },
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
          Container(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Container(
              child: Text('24 Dec, 2019 - Tuesday', style: GoogleFonts.rubik(), textScaleFactor: 1.25,),
            ),
          ),
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
          Container(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Container(
              child: Text('23 Dec, 2019 - Monday', style: GoogleFonts.rubik(), textScaleFactor: 1.25,),
            ),
          ),
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
      )
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}