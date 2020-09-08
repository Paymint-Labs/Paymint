import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paymint/models/models.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExportOutputCsvView extends StatefulWidget {
  @override
  _ExportOutputCsvViewState createState() => _ExportOutputCsvViewState();
}

class _ExportOutputCsvViewState extends State<ExportOutputCsvView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Export output data to CSV',
          style: GoogleFonts.rubik(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'The format is simple. Each line represents the data for a single output and has 7 values:\n\n1) The transaction ID\n2) The output name (label)\n3) The block status (boolean)\n4) The confirmation status (boolean)\n5) The output blockheight\n6) Satoshi value\n7) Output index in transaction',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Center(
              child: MaterialButton(
                onPressed: () async {
                  await outputDataTo2dArray();
                },
                color: Colors.amber,
                textColor: Color(0xff121212),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.save,
                      color: Color(0xff121212),
                    ),
                    SizedBox(width: 8),
                    Text('Save locally to device')
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  outputDataTo2dArray() async {
    // Output Name  --  Output txid  --  Output block status  --
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
    final List<List<String>> formattedData = [];

    final List<UtxoObject> allOutputs = bitcoinService.allOutputs;
    if (allOutputs.length == 0) return 0;

    for (var i = 0; i < allOutputs.length; i++) {
      final List<String> outputDataList = [];

      outputDataList.add(allOutputs[i].txid.toString());
      outputDataList.add(allOutputs[i].txName.toString());
      outputDataList.add(allOutputs[i].blocked.toString());
      outputDataList.add(allOutputs[i].status.confirmed.toString());
      outputDataList.add(allOutputs[i].status.blockHeight.toString());
      outputDataList.add(allOutputs[i].value.toString());
      outputDataList.add(allOutputs[i].vout.toString());

      formattedData.add(outputDataList);
    }

    String csv = ListToCsvConverter().convert(formattedData);
    print(csv);

    final directory = await getExternalStorageDirectory();
    print(directory.path);
    final File file = File('${directory.path}/outputData.csv');
    await file.writeAsString(csv);

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text('Output data successfully exported to CSV', style: TextStyle(color: Colors.white)),
    ));

    return 1;
  }
}
