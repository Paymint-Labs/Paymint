import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paymint/services/services.dart';
import 'dart:io' show Platform;

class BioAuthView extends StatefulWidget {
  BioAuthView({Key key}) : super(key: key);

  @override
  _BioAuthViewState createState() => _BioAuthViewState();
}

class _BioAuthViewState extends State<BioAuthView> {
  @override
  Widget build(BuildContext context) {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Biometric Authentication', style: GoogleFonts.rubik(),),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            onTap: () {},
            title: Text(returnProperText()),
            trailing: FutureBuilder(
              future: bitcoinService.useBiometrics,
              builder: (BuildContext context, AsyncSnapshot<bool> useBio) {
                if (useBio.connectionState == ConnectionState.done) {
                  return Switch.adaptive(
                      value: useBio.data,
                      onChanged: (val) async {
                        await bitcoinService.updateBiometricsUsage();
                      });
                } else {
                  return Switch.adaptive(value: false, onChanged: (val) {});
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

String returnProperText() {
  if (Platform.isAndroid) {
    return 'Enable fingerprint lock';
  } else {
    return 'Enable FaceID/TouchID';
  }
}
