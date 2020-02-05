class ReqBod {
  final String currency;
  final List<String> receivingAddresses;
  final List<String> internalAndChangeAddressArray;

  ReqBod({this.currency, this.receivingAddresses, this.internalAndChangeAddressArray});

  factory ReqBod.fromJson(Map<String, dynamic> json) {
    return ReqBod(
      currency: json['currency'],
      receivingAddresses: json['receivingAddresses'], 
      internalAndChangeAddressArray: json['internalAndChangeAddressArray'] 
    );
  }
}