class Budget {

  final String name;
  final double limit;
  final double spent;

  Budget({
    required this.name,
    required this.limit,
    required this.spent,
  });

  factory Budget.fromJson(Map<String,dynamic> json){

    return Budget(
      name: json["name"],
      limit: double.parse(json["limit_amount"].toString()),
      spent: double.parse(json["spent"].toString()),
    );

  }

}