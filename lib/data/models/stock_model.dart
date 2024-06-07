class Stock {
  final String? id;
  final String drugId;
  final int quantity;

  Stock({
    this.id,
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
  Map<String, dynamic> toJson(Stock stock) {
    return {
      'id': stock.id,
      'drug_id': stock.drugId,
      'remaining_stock': stock.quantity,
    };
  }
}
