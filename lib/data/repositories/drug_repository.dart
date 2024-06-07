import 'package:mystok/data/models/drug_model.dart';
import 'package:mystok/data/models/stock_model.dart';
import 'package:pocketbase/pocketbase.dart';

class DrugRepository {
  final PocketBase pb;

  DrugRepository(this.pb);

  Future<List<Drug>> fetchDrugs() async {
    final records = await pb.collection('drugs').getFullList();
    return records.map((record) => Drug.fromJson(record.toJson())).toList();
  }

  Future<void> addDrug(String name, int stock) async {
    final data = {
      'name': name,
      'stock': stock,
    };
    await pb.collection('drugs').create(body: data);
  }

  Future<void> adjustDrug(String id, int newStock) async {
    final data = {
      'stock': newStock,
    };
    await pb.collection('drugs').update(id, body: data);
  }

  Future<List<Drug>> fetchDrugsByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(Duration(days: 1));
    final filterString =
        '{"created": {"\$gte": "${startDate.toIso8601String()}", "\$lt": "${endDate.toIso8601String()}"}}';
    final records = await pb.collection('drugs').getList(
          filter: filterString,
        );
    return records.items
        .map((record) => Drug.fromJson(record.toJson()))
        .toList();
  }

  Future<Stock?> fetchStockForDrug(String drugId) async {
    final records = await pb.collection('stocks').getFullList(
          filter: 'drug_id="$drugId"',
        );
    if (records.isEmpty) {
      return null;
    }
    return Stock.fromJson(records.first.toJson());
  }

  Future<List<Map<String, dynamic>>> fetchDrugsWithStock() async {
    final drugs = await fetchDrugs();
    final drugWithStockList = <Map<String, dynamic>>[];

    for (var drug in drugs) {
      final stock = await fetchStockForDrug(drug.id);
      drugWithStockList.add({
        'drug': drug,
        'stock': stock,
      });
    }

    return drugWithStockList;
  }
}
