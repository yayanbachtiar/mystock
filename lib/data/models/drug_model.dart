class Drug {
  final String id;
  final String name;
  final int? stock;
  final String strength;
  final String satuan;
  final int? nomorObat;

  Drug(
      {required this.id,
      required this.name,
      this.stock,
      required this.satuan,
      required this.nomorObat,
      required this.strength});

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      name: json['name'],
      stock: json['stock'] ?? 0,
      strength: json['strength'],
      satuan: json['satuan'],
      nomorObat: json['kode'],
    );
  }
}
