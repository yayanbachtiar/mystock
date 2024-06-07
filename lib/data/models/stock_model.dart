class Stock {
  final String id;
  final String drugId;
  final int quantity;

  Stock({
    required this.id,
    required this.drugId,
    required this.quantity,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      drugId: json['drug_id'],
      quantity: json['remaining_stock'],
    );
  }
}
