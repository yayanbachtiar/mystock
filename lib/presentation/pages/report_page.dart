import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/data/models/drug_model.dart';
import 'package:mystok/data/repositories/jurnal_repository.dart';

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
  late Future<List<Drug>> _drugs;

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
        var mapJurnal = <String, int>{};
        var jurnal = widget.jurnalRepository
            .getJurnalByDateLessThan(_selectedDate!)
            .then((jurnal) {
          for (var jurnal in jurnal) {
            var stok = jurnal.kredit - jurnal.debet;
            mapJurnal[jurnal.drugId] = stok;
          }
          return widget.drugRepository.fetchDrugs("");
        }).then((drugs) {
          var updatedDrugs = <Drug>{};
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

          _drugs = Future.value(updatedDrugs.toList());
          print(_drugs);
        });

        // Dapatkan semua obat dari ID obat
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _drugs = Future.value([]); // Default to an empty list
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
            FutureBuilder<List<Drug>>(
              future: _drugs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No drugs available for selected date'));
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final drug = snapshot.data![index];
                        return ListTile(
                          title: Text(drug.name),
                          subtitle: Text('Stock: ${drug.stock}'),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
