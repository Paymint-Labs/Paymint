/// This class is meant for deserializing response objects from the Paymint API.
/// It specifically handles data for the unspent outputs endpoint. This endpoint
/// provides the wallet with a UTXO list and corresponding balances

class UtxoData {
  final String totalUserCurrency;
  final int satoshiBalance;
  final dynamic bitcoinBalance;
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

class UtxoObject {
  final String txid;
  final int vout;
  final Status status;
  final int value;
  final String fiatWorth;
  String txName;
  bool blocked;

  UtxoObject({this.txid, this.vout, this.status, this.value, this.fiatWorth, this.txName, this.blocked});

  factory UtxoObject.fromJson(Map<String, dynamic> json) {
    return UtxoObject(
      txid: json['txid'],
      vout: json['vout'],
      status: Status.fromJson(json['status']),
      value: json['value'],
      fiatWorth: json['fiatWorth'],
      txName: '----',
      blocked: false
    );
  }
}

class Status {
  final bool confirmed;
  final String blockHash;
  final int blockHeight;
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