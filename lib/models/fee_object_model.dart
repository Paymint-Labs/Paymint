class FeeObject {
  final dynamic fast;
  final dynamic medium;
  final dynamic slow;

  FeeObject({this.fast, this.medium, this.slow});

  factory FeeObject.fromJson(Map<String, dynamic> json) {
    return FeeObject(
      fast: json['fast'],
      medium: json['medium'],
      slow: json['slow']
    );
  }
}