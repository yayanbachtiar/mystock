import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/data/models/drug_model.dart';
import 'package:mystok/data/repositories/jurnal_repository.dart';
import 'package:data_table_2/data_table_2.dart';

class ReportPage extends StatefulWidget {
  final DrugRepository drugRepository;
  final JurnalRepository jurnalRepository;

  const ReportPage(
      {super.key,
      required this.drugRepository,
      required this.jurnalRepository});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? _selectedDate;
  Future<List<Drug>>? _drugsFuture;
  List<Drug> _drugs = [];
  List<Drug> _filteredDrugs = [];
  String _searchQuery = '';
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchDrugsWithJurnalData();
      });
    }
  }

  Future<void> _fetchDrugsWithJurnalData() async {
    var mapJurnal = <String, int>{};
    var jurnal =
        await widget.jurnalRepository.getJurnalByDateLessThan(_selectedDate!);

    for (var j in jurnal) {
      var stok = j.kredit - j.debet;
      mapJurnal[j.drugId] = stok;
    }

    var drugs = await widget.drugRepository.fetchDrugs("");
    var updatedDrugs = <Drug>[];

    for (var item in drugs) {
      var update = Drug(
          id: item.id,
          name: item.name,
          satuan: item.satuan,
          nomorObat: item.nomorObat,
          strength: item.strength);
      update.stock = mapJurnal[item.id] ?? 0;
      updatedDrugs.add(update);
    }

    setState(() {
      _drugs = updatedDrugs;
      _filterDrugs();
    });
  }

  void _filterDrugs() {
    setState(() {
      _filteredDrugs = _searchQuery.isEmpty
          ? _drugs
          : _drugs.where((drug) {
              return drug.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _drugsFuture = Future.value([]); // Default to an empty list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Obat per Tanggal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Pilih Tanggal'),
            ),
            SizedBox(height: 20),
            _selectedDate != null
                ? Text(
                    'Tanggal Terpilih: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}')
                : Text('Tidak ada tanggal yang dipilih'),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by Nama Obat or Tanggal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterDrugs();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Drug>>(
                future: _drugsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return PaginatedDataTable2(
                      columns: [
                        DataColumn(label: Text('Nama Obat')),
                        DataColumn(label: Text('Stock')),
                      ],
                      source: DrugDataTableSource(_filteredDrugs),
                      onPageChanged: (page) {},
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (perPage) {
                        setState(() {
                          _rowsPerPage = perPage!;
                        });
                      },
                      sortColumnIndex: 0,
                      sortAscending: true,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrugDataTableSource extends DataTableSource {
  final List<Drug> drugs;

  DrugDataTableSource(this.drugs);

  @override
  DataRow getRow(int index) {
    final drug = drugs[index];
    return DataRow(cells: [
      DataCell(Text(drug.name)),
      DataCell(Text(drug.stock.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => drugs.length;

  @override
  int get selectedRowCount => 0;
}
