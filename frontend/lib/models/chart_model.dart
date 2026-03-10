class ChartData {

  final String category;
  final double total;

  ChartData({
    required this.category,
    required this.total,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {

    return ChartData(
      category: json["name"],
      total: double.parse(json["total"].toString()),
    );

  }

}