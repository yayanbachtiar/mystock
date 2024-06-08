class JurnalObat {
  final String drugId;
  final int debet;
  final int kredit;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String date;
  JurnalObat({
    required this.drugId,
    required this.debet,
    required this.kredit,
    this.note,
    this.createdAt,
    this.updatedAt,
    required this.date,
  });

  factory JurnalObat.fromJson(Map<String, dynamic> json) => JurnalObat(
        drugId: json['obat'],
        debet: json['debet'],
        kredit: json['kredit'],
        note: json['note'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        date: json['date'],
      );

  Map<String, dynamic> toJson() => {
        'obat': drugId,
        'debet': debet,
        'kredit': kredit,
        'note': note,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'date': date,
      };
}
