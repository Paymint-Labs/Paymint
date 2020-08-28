import 'package:flutter/material.dart';

class AdvancedView extends StatefulWidget {
  @override
  _AdvancedViewState createState() => _AdvancedViewState();
}

class _AdvancedViewState extends State<AdvancedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff81D4FA),
        child: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Advanced Settings',
                textScaleFactor: 1.5,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Text(
              'Restore Wallet',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/restorewalletview');
            },
          ),
          ListTile(
            leading: Text(
              'Esplora Server URL',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/esploraview'),
          ),
          ListTile(
            leading: Text(
              'Paymint API URL',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Text(
              'Export output data to CSV',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Text(
              'Restore output data from CSV',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Text(
              'Export transaction data to CSV',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Text(
              'Broadcast raw transaction hex',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
