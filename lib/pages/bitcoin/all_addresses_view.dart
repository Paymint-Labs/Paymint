import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class AllAddressesView extends StatefulWidget {
  AllAddressesView({Key key}) : super(key: key);

  @override
  _AllAddressesViewState createState() => _AllAddressesViewState();
}

class _AllAddressesViewState extends State<AllAddressesView> {
  List<String> previousAddresses = new List();

  _populateAddressArray() async {
    final wallet = await Hive.openBox('wallet');
    final receivingArray = wallet.get('receivingAddresses');

    for (var i = 0; i < receivingArray.length; i++) {
      this.previousAddresses.add(receivingArray[i]);
    }
  }

  String _displayFormatAddress(String address) {
    return address.substring(0, 5) +
        '...' +
        address.substring(address.length - 7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Address book', style: GoogleFonts.rubik()),
      ),
      body: FutureBuilder(
        future: _populateAddressArray(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: previousAddresses.length,
              itemBuilder: (BuildContext context, int index) {
                int i = index + 1;
                if (i == previousAddresses.length) {
                  return ListTile(
                    title: Text('Current: ' +
                        _displayFormatAddress(previousAddresses[index])),
                    onTap: () {},
                    trailing: IconButton(
                        icon: Icon(Icons.content_copy, color: Colors.black),
                        onPressed: () {
                          Clipboard.setData(new ClipboardData(
                              text: previousAddresses[index]));
                          Toast.show('Address copied to clipboard', context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM);
                        }),
                  );
                } else {
                  return ListTile(
                    title: Text('$i) ' +
                        _displayFormatAddress(previousAddresses[index])),
                    onTap: () {},
                    trailing: IconButton(
                        icon: Icon(Icons.content_copy, color: Colors.black),
                        onPressed: () {
                          Clipboard.setData(new ClipboardData(
                              text: previousAddresses[index]));
                          Toast.show('Address copied to clipboard', context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM);
                        }),
                  );
                }
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
