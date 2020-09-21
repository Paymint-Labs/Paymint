import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:paymint/services/bitcoin_service.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'dart:io';

class RestoreOutputCsvView extends StatefulWidget {
  @override
  _RestoreOutputCsvViewState createState() => _RestoreOutputCsvViewState();
}

class _RestoreOutputCsvViewState extends State<RestoreOutputCsvView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  initFilePicker() async {
    final BitcoinService bitcoinService = Provider.of<BitcoinService>(context);
    final String filePath = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: ['csv']);

    if (filePath == null) return 1;

    final wallet = await Hive.openBox('wallet');

    final String csvFile = await File(filePath).readAsString();
    List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(csvFile);
    print(rowsAsListOfValues);

    showModal(
      context: context,
      configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (BuildContext _) {
        return showLoadingModal(_);
      },
    );

    for (var i = 0; i < rowsAsListOfValues.length; i++) {
      final outputRow = rowsAsListOfValues[i];

      final String txid = outputRow[0];
      final String txName = outputRow[1];
      final bool blockStatus = outputRow[2].toLowerCase() == 'true';

      // Calling provider functions
      if (blockStatus == true) bitcoinService.blockOutput(txid);
      bitcoinService.renameOutput(txid, txName);

      // Calling hive functions
      final outputNames = await Hive.openBox('labels');
      await outputNames.put(txid.toString(), txName.toString());

      if (blockStatus == true) {
        final blockedList = await wallet.get('blocked_tx_hashes');
        final blockedCopy = new List();
        for (var i = 0; i < blockedList.length; i++) {
          blockedCopy.add(blockedList[i]);
        }
        blockedCopy.add(txid.toString());
        await wallet.put('blocked_tx_hashes', blockedCopy);
      }
    }

    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context);

    showModal(
      context: context,
      configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (BuildContext _) {
        return restorationSuccessModal(_);
      },
    );
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
          'Restore output data from CSV',
          style: GoogleFonts.rubik(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Pick a CSV file from your device that conforms to the CSV format that Paymint exports output data to and it\'ll restore output labels and block status.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'A restart will be required after data restoration.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 12),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_backup_restore,
                  color: Color(0xff121212),
                ),
                SizedBox(width: 12),
                Text('Restore from CSV', style: TextStyle(color: Color(0xff121212)))
              ],
            ),
            onPressed: () async => await initFilePicker(),
            color: Colors.amber,
          ),
        ],
      ),
    );
  }
}

AlertDialog showLoadingModal(BuildContext _) {
  return AlertDialog(
    title: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 12),
        Text('Restoring data', style: TextStyle(color: Colors.white)),
      ],
    ),
    content: Text('Please be patient...', style: TextStyle(color: Colors.white)),
  );
}

AlertDialog restorationSuccessModal(BuildContext _) {
  return AlertDialog(
    title: Text('Data successfully restored', style: TextStyle(color: Colors.white)),
    actions: [FlatButton(onPressed: () => Navigator.pop(_), child: Text('OK'))],
  );
}
