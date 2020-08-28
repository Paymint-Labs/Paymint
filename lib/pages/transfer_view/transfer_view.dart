import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferView extends StatefulWidget {
  TransferView({Key key}) : super(key: key);

  @override
  _TransferViewState createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Color(0xff121212),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    child: Ink(
                      decoration: BoxDecoration(color: Color(0xff81D4FA)),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/receive');
                        },
                        child: Container(
                          height: 85,
                          width: 85,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 50,
                            color: Color(0xff121212),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Receive Bitcoin',
                  style: TextStyle(color: Color(0xff81D4FA)),
                ),
                SizedBox(height: 48),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color(0xff81D4FA),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/send');
                        },
                        child: Container(
                          height: 85,
                          width: 85,
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 50,
                            color: Color(0xff121212),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Send Bitcoin',
                  style: TextStyle(color: Color(0xff81D4FA)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
