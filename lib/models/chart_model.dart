class ChartModel {
  final List<dynamic> xAxis;
  final List<dynamic> candleData;

  ChartModel({this.xAxis, this.candleData});

  factory ChartModel.fromJson(Map<String, dynamic> json) {
    return ChartModel(
      xAxis: json["xAxis"],
      candleData: json["candleData"],
    );
  }
}
