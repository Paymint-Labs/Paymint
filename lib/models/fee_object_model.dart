class FeeObject {
  final double fast;
  final double medium;
  final double slow;

  FeeObject({this.fast, this.medium, this.slow});

  factory FeeObject.fromJson(Map<String, dynamic> json) {
    return FeeObject(
      fast: json['fast'],
      medium: json['medium'],
      slow: json['slow']
    );
  }
}