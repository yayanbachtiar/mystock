import 'package:mystok/data/models/jurnal_model.dart';
import 'package:pocketbase/pocketbase.dart';

class JurnalRepository {
  final PocketBase client;

  JurnalRepository(this.client);

  Future<void> addJurnal(JurnalObat jurnal) async {
    await client.collection('jurnals').create(body: jurnal.toJson());
  }

  Future<List<JurnalObat>> getJurnalByDateLessThan(DateTime date) async {
    final response = await client.collection('jurnals').getList(
          filter: 'createdAt < "${date.toIso8601String()}"',
        );

    return response.items
        .map((record) => JurnalObat.fromJson(record.toJson()))
        .toList();
  }
}
