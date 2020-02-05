/// This class is meant for deserializing response objects from the Paymint API.
/// It specifically handles data for the unspent outputs endpoint. This endpoint
/// provides the wallet with a UTXO list and corresponding balances
/// 

class UtxoData {
  final int satoshiBalance;
  final double bitcoinBalance;
  final List<UtxoObject> unspentOutputArray;

  UtxoData({this.satoshiBalance, this.bitcoinBalance, this.unspentOutputArray});

  factory UtxoData.fromJson(Map<String, dynamic> json) {
    var list = json['outputArray'] as List;
    List<UtxoObject> utxoList = list.map((i) => UtxoObject.fromJson(i)).toList(); 
    
    return UtxoData(
      satoshiBalance: json['total_sats'],
      bitcoinBalance: json['total_btc'],
      unspentOutputArray: utxoList
    );
  }
}

class UtxoObject {
  final String txid;
  final String vout;
  final Status status;
  final int value;

  UtxoObject({this.txid, this.vout, this.status, this.value});

  factory UtxoObject.fromJson(Map<String, dynamic> json) {
    return UtxoObject(
      txid: json['txid'],
      vout: json['vout'],
      status: Status.fromJson(json['status']),
      value: json['value']
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