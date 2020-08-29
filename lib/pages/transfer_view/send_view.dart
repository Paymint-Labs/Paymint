import 'package:flutter/material.dart';

class SendView extends StatefulWidget {
  SendView({Key key}) : super(key: key);

  @override
  _SendViewState createState() => _SendViewState();
}

class _SendViewState extends State<SendView> {
  String recipientAddress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff121212),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'Send Bitcoin',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: PageView(
                children: [_buildAddRecipientView()],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// The container that allows user to supply data to [recipeintAddress]
  _buildAddRecipientView() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(helperText: 'Recipient\'s Address'),
            ),
            SizedBox(height: 16),
            MaterialButton(
              onPressed: () {},
              child: Text(
                'Continue',
                style: TextStyle(color: Color(0xff121212)),
              ),
              color: Color(0xff81D4FA),
            )
          ],
        ),
      ),
    );
  }
}
