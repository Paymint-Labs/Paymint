import 'package:hive/hive.dart';

part 'type_adaptors/utxo_model.g.dart';

// @HiveType(typeId: 6)
class UtxoData {
  // @HiveField(0)
  final String totalUserCurrency;
  // @HiveField(1)
  final int satoshiBalance;
  // @HiveField(2)
  final dynamic bitcoinBalance;
  // @HiveField(3)
  List<UtxoObject> unspentOutputArray;

  UtxoData({this.totalUserCurrency, this.satoshiBalance, this.bitcoinBalance, this.unspentOutputArray});

  factory UtxoData.fromJson(Map<String, dynamic> json) {
    var outputList = json['outputArray'] as List;
    List<UtxoObject> utxoList = outputList.map((output) => UtxoObject.fromJson(output)).toList(); 
    final String totalUserCurr = json['total_user_currency']; 
    final double totalBtc = json['total_btc'].toDouble(); 
    
    return UtxoData(
      totalUserCurrency: totalUserCurr,
      satoshiBalance: json['total_sats'],
      bitcoinBalance: totalBtc,
      unspentOutputArray: utxoList
    );
  }
}

// @HiveType(typeId: 7)
class UtxoObject {
  // @HiveField(0)
  final String txid;
  // @HiveField(1)
  final int vout;
  // @HiveField(2)
  final Status status;
  // @HiveField(3)
  final int value;
  // @HiveField(4)
  final String fiatWorth;
  // @HiveField(5)
  String txName;
  // @HiveField(6)
  bool blocked;

  UtxoObject({this.txid, this.vout, this.status, this.value, this.fiatWorth, this.txName, this.blocked});

  factory UtxoObject.fromJson(Map<String, dynamic> json) {
    return UtxoObject(
      txName: '----',
      txid: json['txid'],
      vout: json['vout'],
      status: Status.fromJson(json['status']),
      value: json['value'],
      fiatWorth: json['fiatWorth'],
      blocked: false
    );
  }
}

// @HiveType(typeId: 8)
class Status {
  // @HiveField(0)
  final bool confirmed;
  // @HiveField(1)
  final String blockHash;
  // @HiveField(2)
  final int blockHeight;
  // @HiveField(3)
  final int blockTime;

  Status({this.confirmed, this.blockHash, this.blockHeight, this.blockTime});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      confirmed: json['confirmed'],
      blockHash: json['block_hash'],
      blockHeight: json['block_height'],
      blockTime: json['block_time']
    );
  }
}