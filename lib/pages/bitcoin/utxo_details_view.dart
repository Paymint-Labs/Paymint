import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:paymint/models/models.dart';

class UtxoDetailView extends StatefulWidget {
  final UtxoObject output;
  
  UtxoDetailView({Key key, @required this.output}) : super(key: key);

  @override
  _UtxoDetailViewState createState() => _UtxoDetailViewState(output);
}

class _UtxoDetailViewState extends State<UtxoDetailView> {
  final UtxoObject _utxoObject;

  _UtxoDetailViewState(this._utxoObject);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_utxoObject.txName + ' Details'),
      ),
      body: ListView(
        
      ),
    );
  }
}