import 'dart:async'; // Tambahkan ini untuk Timer
import 'package:flutter/material.dart';
import 'package:mystok/data/repositories/auth_repository.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/data/models/drug_model.dart';
import 'package:mystok/data/models/stock_model.dart';

class DrugListPage extends StatefulWidget {
  final DrugRepository drugRepository;
  final AuthRepository authRepository;

  DrugListPage({required this.drugRepository, required this.authRepository});

  @override
  _DrugListPageState createState() => _DrugListPageState();
}

class _DrugListPageState extends State<DrugListPage> {
  late Future<List<Map<String, dynamic>>> _drugsWithStock;
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _drugsWithStock = widget.drugRepository.fetchDrugsWithStock('');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // Call your search method here
      setState(() {
        _drugsWithStock =
            widget.drugRepository.fetchDrugsWithStock(_searchController.text);
      });
    });
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void _logout() async {
    await widget.authRepository.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Obat'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _drugsWithStock = widget.drugRepository
                    .fetchDrugsWithStock(_searchController.text);
              });
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateTo('/receiveDrug'),
            tooltip: 'Receive Drug',
          ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () => _navigateTo('/importDrug'),
            tooltip: 'Import Drug',
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () => _navigateTo('/issueDrug'),
            tooltip: 'Issue Drug',
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateTo('/adjustDrug'),
            tooltip: 'Adjust Drug',
          ),
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () => _navigateTo('/report'),
            tooltip: 'Report',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari berdasarkan Nama Obat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _onSearchChanged();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _drugsWithStock,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No drugs available'));
                } else {
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: constraints.maxWidth),
                            child: IntrinsicWidth(
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('Nama Obat')),
                                  DataColumn(label: Text('Satuan')),
                                  DataColumn(label: Text('Stock')),
                                ],
                                rows: snapshot.data!.map((item) {
                                  final drug = item['drug'] as Drug;
                                  final stock = item['stock'] as Stock?;

                                  return DataRow(cells: [
                                    DataCell(Text(drug.name)),
                                    DataCell(Text(drug.satuan)),
                                    DataCell(Text(
                                        stock?.quantity.toString() ?? 'N/A')),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
