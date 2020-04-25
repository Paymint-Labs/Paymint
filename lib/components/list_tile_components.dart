/**
 * ListTile Widgets for the Activity and Security View.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

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
  ContainerTransitionType _transitionType = ContainerTransitionType.fade;

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
            style: GoogleFonts.rubik(),
          ),
          subtitle: Text(
            widget.amount + ' BTC',
            style: GoogleFonts.rubik(),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '\$' + widget.previousValue + ' when sent',
                style: GoogleFonts.rubik(),
              ),
              Text(
                '\$' + widget.currentValue + ' now',
                style: GoogleFonts.rubik(),
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
            style: GoogleFonts.rubik(),
          ),
          subtitle: Text(
            amount + ' BTC',
            style: GoogleFonts.rubik(),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '\$' + previousValue + ' when received',
                style: GoogleFonts.rubik(),
              ),
              Text(
                '\$' + currentValue + ' now',
                style: GoogleFonts.rubik(),
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
        style: GoogleFonts.rubik(),
      ),
      subtitle: Text(
        purchaseAmount + ' BTC',
        style: GoogleFonts.rubik(),
      ),
      trailing: Text(
        '\$' + valueAtTimeOfPurchase + ' when bought',
        style: GoogleFonts.rubik(),
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

const String _loremIpsumParagraph =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Vulputate dignissim '
    'suspendisse in est. Ut ornare lectus sit amet. Eget nunc lobortis mattis '
    'aliquam faucibus purus in. Hendrerit gravida rutrum quisque non tellus '
    'orci ac auctor. Mattis aliquam faucibus purus in massa. Tellus rutrum '
    'tellus pellentesque eu tincidunt tortor. Nunc eget lorem dolor sed. Nulla '
    'at volutpat diam ut venenatis tellus in metus. Tellus cras adipiscing enim '
    'eu turpis. Pretium fusce id velit ut tortor. Adipiscing enim eu turpis '
    'egestas pretium. Quis varius quam quisque id. Blandit aliquam etiam erat '
    'velit scelerisque. In nisl nisi scelerisque eu. Semper risus in hendrerit '
    'gravida rutrum quisque. Suspendisse in est ante in nibh mauris cursus '
    'mattis molestie. Adipiscing elit duis tristique sollicitudin nibh sit '
    'amet commodo nulla. Pretium viverra suspendisse potenti nullam ac tortor '
    'vitae.\n'
    '\n'
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Vulputate dignissim '
    'suspendisse in est. Ut ornare lectus sit amet. Eget nunc lobortis mattis '
    'aliquam faucibus purus in. Hendrerit gravida rutrum quisque non tellus '
    'orci ac auctor. Mattis aliquam faucibus purus in massa. Tellus rutrum '
    'tellus pellentesque eu tincidunt tortor. Nunc eget lorem dolor sed. Nulla '
    'at volutpat diam ut venenatis tellus in metus. Tellus cras adipiscing enim '
    'eu turpis. Pretium fusce id velit ut tortor. Adipiscing enim eu turpis '
    'egestas pretium. Quis varius quam quisque id. Blandit aliquam etiam erat '
    'velit scelerisque. In nisl nisi scelerisque eu. Semper risus in hendrerit '
    'gravida rutrum quisque. Suspendisse in est ante in nibh mauris cursus '
    'mattis molestie. Adipiscing elit duis tristique sollicitudin nibh sit '
    'amet commodo nulla. Pretium viverra suspendisse potenti nullam ac tortor '
    'vitae';

class _DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details page'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(70.0),
              child: Container(
                height: 100,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Title',
                  // TODO(shihaohong): Remove this once Flutter stable adopts the modern
                  // Material text style nomenclature.
                  // ignore: deprecated_member_use
                  style: Theme.of(context).textTheme.headline.copyWith(
                        color: Colors.black54,
                        fontSize: 30.0,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  _loremIpsumParagraph,
                  // TODO(shihaohong): Remove this once Flutter stable adopts the modern
                  // Material text style nomenclature.
                  // ignore: deprecated_member_use
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.black54,
                        height: 1.5,
                        fontSize: 16.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
