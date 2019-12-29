import 'package:flutter/material.dart';


class PopUpDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PopUpDialogState();
}

class PopUpDialogState extends State<PopUpDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  Container _buildFabTiles() {
    return Container(height: 150, child: Text('This is cool'));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: _buildFabTiles(),
            ),
          ),
        ),
      ),
    );
  }
}
