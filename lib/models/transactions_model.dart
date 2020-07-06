import 'package:hive/hive.dart';

part 'type_adaptors/transactions_model.g.dart';

@HiveType(typeId: 1)
class TransactionData {
  @HiveField(0)
  final List<TransactionChunk> txChunks;

  TransactionData({this.txChunks});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    var dateTimeChunks = json['dateTimeChunks'] as List;
    List<TransactionChunk> chunksList = dateTimeChunks.map((txChunk) => TransactionChunk.fromJson(txChunk)).toList();
    
    return TransactionData(
      txChunks: chunksList
    );
  }
}

@HiveType(typeId: 2)
class TransactionChunk {
  @HiveField(0)
  final int timestamp;
  @HiveField(1)
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

@HiveType(typeId: 3)
class Transaction {
  @HiveField(0)
  final String txid;
  @HiveField(1)
  final bool confirmedStatus;
  @HiveField(2)
  final int timestamp;
  @HiveField(3)
  final String txType;
  @HiveField(4)
  final int amount;
  @HiveField(5)
  final List aliens;
  /// Keep worthNow as dynamic
  @HiveField(6)
  final dynamic worthNow;
  /// worthAtBlockTimestamp has to be dynamic in case the server fucks up the price quote and returns null instead of a double
  @HiveField(7)
  final dynamic worthAtBlockTimestamp;
  @HiveField(8)
  final int fees;
  @HiveField(9)
  final int inputSize;
  @HiveField(10)
  final int outputSize;
  @HiveField(11)
  final List<Input> inputs;
  @HiveField(12)
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

@HiveType(typeId: 4)
class Input {
  @HiveField(0)
  final String txid;
  @HiveField(1)
  final int vout;
  @HiveField(2)
  final Output prevout;
  @HiveField(3)
  final String scriptsig;
  @HiveField(4)
  final String scriptsigAsm;
  @HiveField(5)
  final List<dynamic> witness;
  @HiveField(6)
  final bool isCoinbase;
  @HiveField(7)
  final int sequence;
  @HiveField(8)
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

@HiveType(typeId: 5)
class Output {
  @HiveField(0)
  final String scriptpubkey;
  @HiveField(1)
  final String scriptpubkeyAsm;
  @HiveField(2)
  final String scriptpubkeyType;
  @HiveField(3)
  final String scriptpubkeyAddress;
  @HiveField(4)
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
