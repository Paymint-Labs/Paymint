/**
 * ListTile Widgets for the Activity and Security View.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:flare_flutter/flare_actor.dart';

class SendListTile extends StatefulWidget {
  SendListTile({Key key, this.amount, this.currentValue, this.previousValue})
      : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  @override
  _SendListTileState createState() => _SendListTileState();
}

class _SendListTileState extends State<SendListTile> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: this._transitionType,
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        return _DetailsPage();
      },
      tappable: true,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: Icon(Icons.keyboard_arrow_up, color: Colors.pink, size: 40),
          title: Text(
            'Sent',
          ),
          subtitle: Text(
            widget.amount + ' BTC',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '\$' + widget.previousValue + ' when sent',
              ),
              Text(
                '\$' + widget.currentValue + ' now',
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReceiveListTile extends StatelessWidget {
  const ReceiveListTile(
      {Key key, this.amount, this.currentValue, this.previousValue})
      : super(key: key);

  final String amount;
  final String currentValue;
  final String previousValue;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        return _DetailsPage();
      },
      tappable: true,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: Icon(Icons.keyboard_arrow_down,
              color: Colors.blueAccent, size: 40),
          title: Text(
            'Received',
          ),
          subtitle: Text(
            amount + ' BTC',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '\$' + previousValue + ' when received',
              ),
              Text(
                '\$' + currentValue + ' now',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PurchaseListTile extends StatelessWidget {
  const PurchaseListTile(
      {Key key, this.purchaseAmount, this.valueAtTimeOfPurchase})
      : super(key: key);

  final String purchaseAmount; // Denominated in BTC
  final String
      valueAtTimeOfPurchase; // USD value of purchaseAmount at the time of the purchase

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Icon(
        Icons.show_chart,
        color: Colors.black,
        size: 30,
      ),
      title: Text(
        'Purchased ',
      ),
      subtitle: Text(
        purchaseAmount + ' BTC',
      ),
      trailing: Text(
        '\$' + valueAtTimeOfPurchase + ' when bought',
      ),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    this.closedBuilder,
    this.transitionType,
  });

  final OpenContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return _DetailsPage();
      },
      tappable: false,
      closedBuilder: closedBuilder,
    );
  }
}

/// Widget for the default view for transaction details
class _DetailsPage extends StatefulWidget {
  @override
  __DetailsPageState createState() => __DetailsPageState();
}

class __DetailsPageState extends State<_DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transaction details',
            style: GoogleFonts.rubik(
              textStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 10,
        ),
        body: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.width / 2,
                color: Colors.black,
                child: Center(
                    child: FlareActor('assets/rive/success.flr',
                        animation: 'Untitled'))),
            ListTile(
              title: Text('Date/Time:'),
              trailing: Text('23 Oct, 2019 - 5:05 PM'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Action:'),
              trailing: Text('Sent'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Amount:'),
              trailing: Text('0.1839573 BTC'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth now:'),
              trailing: Text('\$294.83'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Worth when sent:'),
              trailing: Text('\$292.21'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Balance delta:'),
              trailing: Text('Lost \$2.75 in transaction'),
              onTap: () {},
            )
          ],
        ));
  }
}
