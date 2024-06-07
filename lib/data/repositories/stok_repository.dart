import 'package:mystok/data/models/stock_model.dart';
import 'package:pocketbase/pocketbase.dart';

class StockRepository {
  final PocketBase client;

  StockRepository(this.client);

  Future<Stock?> fetchStockByDrugId(String drugId) async {
    final response = await client.collection('stocks').getList(
          filter: '(drug_id = "$drugId")',
        );

    if (response.items.isNotEmpty) {
      return response.items.map((record) => Stock.fromJson(record.data)).first;
    }
    return null;
  }

  Future<void> updateStock(Stock stock) async {
    await client
        .collection('stocks')
        .update(stock.id!, body: stock.toJson(stock));
  }

  Future<void> tambahStock(Stock stock) async {
    await client.collection('stocks').create(body: stock.toJson(stock));
  }
}
