import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/services.dart';
import 'package:flutter/cupertino.dart';

class EsploraView extends StatefulWidget {
  @override
  _EsploraViewState createState() => _EsploraViewState();
}

class _EsploraViewState extends State<EsploraView> {
  TextEditingController textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);

    return Scaffold(
      backgroundColor: Color(0xff121212),
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: CupertinoButton.filled(
            onPressed: () async {
              final wallet = await Hive.openBox('wallet');

              if (textController.text.isEmpty || textController.text.trim() == '') {
                await wallet.put('esplora_url', 'https://www.blockstream.info/api');
              } else {
                await wallet.put('esplora_url', textController.text);
              }
            },
            child: Text('Save changes'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Input the publicly accessible url of your Esplora-Electrs server below. Leaving it blank will default to Blockstream servers',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            FutureBuilder(
              future: bitcoinService.getEsploraUrl(),
              builder: (BuildContext context, AsyncSnapshot<String> esploraUrl) {
                if (esploraUrl.connectionState == ConnectionState.done) {
                  return TextField(
                    controller: textController,
                    autofocus: true,
                    showCursor: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Server URL',
                      hintText: esploraUrl.data,
                    ),
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
