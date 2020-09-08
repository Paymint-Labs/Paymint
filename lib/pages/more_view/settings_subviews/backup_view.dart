import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupView extends StatefulWidget {
  @override
  _BackupViewState createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  _setMnemonic() async {
    final secureStore = new FlutterSecureStorage();
    final mnemonicString = await secureStore.read(key: 'mnemonic');
    final List<String> data = mnemonicString.split(' ');
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff121212),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.cyanAccent,
              ),
              onPressed: () => Navigator.pop(context)),
          title: Text(
            'Your secret words',
            style: GoogleFonts.rubik(color: Colors.white),
          ),
        ),
        backgroundColor: Color(0xff121212),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Write these words down on some sort of secure physical medium that you will not eaily lose. They allow you to restore your wallet in case you lose your phone or it\'s memory gets wiped unexpectedly.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: FutureBuilder(
            future: _setMnemonic(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final i = index + 1;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '$i: ' + snapshot.data[index],
                            textScaleFactor: 1.3,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
