class TransactionModel {

  final String id;
  final double amount;
  final String type;
  final String description;
  final String date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {

    return TransactionModel(
      id: json["id"],
      amount: double.parse(json["amount"].toString()),
      type: json["type"],
      description: json["description"] ?? "",
      date: json["date"]
    );

  }

  Object? get categoryId => null;

}