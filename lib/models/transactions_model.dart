/// This class is meant for deserializing response objects from the Paymint API.
/// It specifically handles data for the transactions endpoint. This endpoint
/// provides the wallet with ordered transaction chunks with  
///

class TransactionData {
  final List<TransactionChunk> txChunks;

  TransactionData({this.txChunks});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    var txChunkArray = json['txChunks'] as List;
    List<TransactionChunk> txChunkList = txChunkArray.map((txChunk) => TransactionChunk.fromJson(txChunk)).toList();
    
    return TransactionData(
      txChunks: txChunkList
    );
  }
}

class TransactionChunk {
  final int timestamp;
  final List<Transaction> transactions;

  TransactionChunk({this.timestamp, this.transactions});

  factory TransactionChunk.fromJson(Map<String, dynamic> json) {
    var txArray = json['transactions'] as List;
    List<Transaction> txList = txArray.map((tx) => Transaction.fromJson(tx)).toList();
    
    return TransactionChunk(
      timestamp: json['timestamp'],
      transactions: txList
    );
  }
}

class Transaction {
  final String txid;
  final bool confirmedStatus;
  final int timestamp;
  final String txType;
  final int amount;
  final List aliens;
  final String worthNow;
  final String worthAtBlockTimestamp;
  final int fees;
  final int inputSize;
  final int outputSize;
  final List<Input> inputs;
  final List<Output> outputs;

  Transaction({this.txid, this.confirmedStatus, this.timestamp, this.txType, this.amount, this.aliens, this.worthNow, this.worthAtBlockTimestamp,
  this.fees, this.inputSize, this.outputSize, this.inputs, this.outputs });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    var inputArray = json['inputs'] as List;
    var outputArray = json['outputs'] as List;

    List<Input> inputList = inputArray.map((input) => Input.fromJson(input)).toList();
    List<Output> outputList = outputArray.map((output) => Output.fromJson(output)).toList();

    return Transaction(
      txid: json['txid'],
      confirmedStatus: json['confirmed_status'],
      timestamp: json['timestamp'],
      txType: json['txType'],
      amount: json['amount'],
      aliens: json['aliens'],
      worthNow: json['worthNow'],
      worthAtBlockTimestamp: json['worthAtBlockTimestamp'],
      fees: json['fees'],
      inputSize: json['inputSize'],
      outputSize: json['outputSize'],
      inputs: inputList,
      outputs: outputList
    );
  }
}

class Input {
  final String txid;
  final int vout;
  final Output prevout;
  final String scriptsig;
  final String scriptsigAsm;
  final List<String> witness;
  final bool isCoinbase;
  final int sequence;
  final String innerRedeemscriptAsm;

  Input({this.txid, this.vout, this.prevout, this.scriptsig, this.scriptsigAsm, this.witness, this.isCoinbase, this.sequence, this.innerRedeemscriptAsm });

  factory Input.fromJson(Map<String, dynamic> json) {
    return Input(
      txid: json['txid'],
      vout: json['vout'],
      prevout: Output.fromJson(json['prevout']),
      scriptsig: json['scriptsig'],
      scriptsigAsm: json['scriptsig_asm'],
      witness: json['witness'],
      isCoinbase: json['is_coinbase'],
      sequence: json['sequence'],
      innerRedeemscriptAsm: json['innerRedeemscriptAsm']
    );
  }

}

class Output {
  final String scriptpubkey;
  final String scriptpubkeyAsm;
  final String scriptpubkeyType;
  final String scriptpubkeyAddress;
  final int value;

  Output({this.scriptpubkey, this.scriptpubkeyAsm, this.scriptpubkeyType, this.scriptpubkeyAddress, this.value});

  factory Output.fromJson(Map<String, dynamic> json) {
    return Output(
      scriptpubkey: json['scriptpubkey'],
      scriptpubkeyAsm: json['scriptpubkey_asm'],
      scriptpubkeyType: json['scriptpubkey_type'],
      scriptpubkeyAddress: json['scriptpubkey_address'],
      value: json['value'],
    );
  }
}
