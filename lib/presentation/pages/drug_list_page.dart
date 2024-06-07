import 'package:flutter/material.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/data/models/drug_model.dart';
import 'package:mystok/data/models/stock_model.dart';

class DrugListPage extends StatefulWidget {
  final DrugRepository drugRepository;

  DrugListPage({required this.drugRepository});

  @override
  _DrugListPageState createState() => _DrugListPageState();
}

class _DrugListPageState extends State<DrugListPage> {
  late Future<List<Map<String, dynamic>>> _drugsWithStock;

  @override
  void initState() {
    super.initState();
    _drugsWithStock = widget.drugRepository.fetchDrugsWithStock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Obat'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _drugsWithStock,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No drugs available'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Nama Obat')),
                        DataColumn(label: Text('Nomor Obat')),
                        DataColumn(label: Text('Satuan')),
                        DataColumn(label: Text('Stock')),
                      ],
                      rows: snapshot.data!.map((item) {
                        final drug = item['drug'] as Drug;
                        final stock = item['stock'] as Stock?;

                        return DataRow(cells: [
                          DataCell(Text(drug.name)),
                          DataCell(Text(drug.nomorObat.toString())),
                          DataCell(Text(drug.satuan)),
                          DataCell(Text(stock?.quantity.toString() ?? 'N/A')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
