import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class AddressBookView extends StatefulWidget {
  @override
  _AddressBookViewState createState() => _AddressBookViewState();
}

class _AddressBookViewState extends State<AddressBookView> {
  List<String> previousAddresses = new List();

  _populateAddressArray() async {
    final wallet = await Hive.openBox('wallet');
    final receivingArray = wallet.get('receivingAddresses');

    for (var i = 0; i < receivingArray.length; i++) {
      this.previousAddresses.add(receivingArray[i]);
    }
  }

  String _displayFormatAddress(String address) {
    return address.substring(0, 5) + '...' + address.substring(address.length - 7);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff121212),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Address Book',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            FutureBuilder(
              future: _populateAddressArray(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    height: MediaQuery.of(context).size.height - 100,
                    child: ListView.builder(
                      itemCount: previousAddresses.length,
                      itemBuilder: (BuildContext context, int index) {
                        int i = index + 1;
                        if (i == previousAddresses.length) {
                          return ListTile(
                            title: Text(
                              'Current: ' + _displayFormatAddress(previousAddresses[index]),
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {},
                            trailing: IconButton(
                                icon: Icon(Icons.content_copy, color: Colors.cyanAccent),
                                onPressed: () {
                                  Clipboard.setData(new ClipboardData(text: previousAddresses[index]));
                                  Toast.show('Address copied to clipboard', context,
                                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }),
                          );
                        } else {
                          return ListTile(
                            title: Text(
                              '$i) ' + _displayFormatAddress(previousAddresses[index]),
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {},
                            trailing: IconButton(
                                icon: Icon(Icons.content_copy, color: Colors.cyanAccent),
                                onPressed: () {
                                  Clipboard.setData(new ClipboardData(text: previousAddresses[index]));
                                  Toast.show('Address copied to clipboard', context,
                                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }),
                          );
                        }
                      },
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
