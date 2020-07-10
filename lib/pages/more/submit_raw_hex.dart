import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:animations/animations.dart';

class SubmitRawTxHexView extends StatefulWidget {
  @override
  _SubmitRawTxHexViewState createState() => _SubmitRawTxHexViewState();
}

class _SubmitRawTxHexViewState extends State<SubmitRawTxHexView> {
  TextEditingController textController = new TextEditingController();
  RoundedLoadingButtonController roundButtonController =
      new RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
  }

  void pushtx(BuildContext context) async {
    bool res = await _submitHexToNetwork(textController.text.trim());
    if (res) {
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _TransactionSuccessDialog();
        },
      );
    } else {
      Navigator.pop(context);
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(),
        builder: (BuildContext context) {
          return _TransactionFailureDialod();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
            child: RoundedLoadingButton(
          color: Colors.black,
          child: Text(
            'Submit transaction',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            pushtx(context);
          },
        )),
      ),
      appBar: AppBar(
        title: Text('Submit raw transaction', style: GoogleFonts.rubik()),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Please paste the raw transaction in hex form into the text box shown below.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: textController,
              autofocus: true,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<bool> _submitHexToNetwork(String hex) async {
  final Map<String, dynamic> obj = {"hex": hex};

  final res = await http.post(
    'https://www.api.paymintapp.com/btc/pushtx',
    body: jsonEncode(obj),
    headers: {'Content-Type': 'application/json'},
  );

  if (res.statusCode == 200 || res.statusCode == 201) {
    return true;
  } else {
    return false;
  }
}

class _TransactionSuccessDialog extends StatelessWidget {
  const _TransactionSuccessDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transaction successful!'),
      content: Container(
        height: 80,
        child: Center(
            child: Icon(Icons.check_circle, color: Colors.green, size: 70)),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}

class _TransactionFailureDialod extends StatelessWidget {
  const _TransactionFailureDialod({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transaction unsuccessful!'),
      content: Text('Please try again'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}
