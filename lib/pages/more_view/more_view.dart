import 'package:flutter/material.dart';

class MoreView extends StatefulWidget {
  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      body: ListView(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Settings',
                textScaleFactor: 1.5,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Text(
              'General',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/generalview');
            },
          ),
          ListTile(
            leading: Text(
              'Advanced',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/advancedview');
            },
          ),
          ListTile(
            leading: Text(
              'Backup wallet',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Text(
              'About Us',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Text(
              'Learn about Bitcoin',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.info),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
