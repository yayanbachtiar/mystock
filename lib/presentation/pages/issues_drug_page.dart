import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:mystok/data/models/issue_model.dart';
import 'package:mystok/data/models/jurnal_model.dart';
import 'package:mystok/data/models/stock_model.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/data/repositories/issue_repository.dart';
import 'package:mystok/data/repositories/jurnal_repository.dart';
import 'package:mystok/data/repositories/stok_repository.dart';

class IssuesDrugPage extends StatefulWidget {
  final DrugRepository drugRepository;
  final IssueRepository issueRepository;
  final StockRepository stockRepository;

  final JurnalRepository jurnalRepository;

  const IssuesDrugPage({
    super.key,
    required this.drugRepository,
    required this.issueRepository,
    required this.stockRepository,
    required this.jurnalRepository,
    // required this.currentUser,
  });

  @override
  _IssuesDrugPageState createState() => _IssuesDrugPageState();
}

class _IssuesDrugPageState extends State<IssuesDrugPage> {
  final TextEditingController _monthController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;
  String _message = '';
  DateTime? _selectedMonth;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _importData() async {
    if (_selectedFile == null || _monthController.text.isEmpty) {
      setState(() {
        _message = 'Please select a file and enter the month.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    var bytes = _selectedFile!.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables.keys.contains('Sheet1')
        ? excel.tables['Sheet1']
        : excel.tables.values.first;
    var rows = sheet?.rows;

    if (rows == null || rows.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Excel file is empty or not properly formatted.';
      });
      return;
    }

    var batchId = UniqueKey().toString();

    for (var i = 1; i < rows.length; i++) {
      var row = rows[i];
      var drugName = row[0]?.value;
      if (drugName == null || drugName == '') continue;

      var drug = await widget.drugRepository.fetchDrugs(drugName.toString());
      if (drug.isEmpty) {
        continue;
      }
      Map<String, int> qtyByDrugId = {};

      for (var j = 1; j < 31; j++) {
        var dateValue = row[j + 1]?.value;
        if (dateValue == null || dateValue == '') continue;

        var quantity = int.tryParse(dateValue.toString());
        if (quantity == null) continue;

        var parts = _monthController.text.split('-');
        if (parts.length != 2) {
          setState(() {
            _message = 'Month format is incorrect.';
          });
          continue;
        }

        var year = int.tryParse(parts[0]);
        var month = int.tryParse(parts[1]);

        if (year == null || month == null) {
          setState(() {
            _message = 'Year or month format is incorrect.';
          });
          continue;
        }

        var day = j;

        if (!_isValidDate(year, month, day)) {
          print('Invalid date: $year-$month-$day');
          continue;
        }

        var date = DateTime.parse(
            _monthController.text + '-' + j.toString().padLeft(2, '0'));

        // print(date.toIso8601String());
        var existingIssue = await widget.issueRepository
            .fetchIssueByDrugAndDate(drug[0].id, date)
            .catchError((err) {
          print(err);
        });

        if (existingIssue != null) {
          setState(() {
            _message = 'Data for "$drugName" on "$date" already exists.';
          });
          continue;
        }
        var key = '${drug[0].id}-${date.toString().substring(0, 10)}';
        var newIssue = Issue(
          key: key,
          drugId: drug[0].id,
          date: date,
          quantity: quantity,
          batchId: batchId,
        );

        var drugQty = qtyByDrugId[drug[0].id] ?? 0;
        drugQty += quantity;
        qtyByDrugId[drug[0].id] = drugQty;

        await widget.issueRepository.tambahIssue(newIssue).catchError((err) {
          print(err);
        });

        var jurnal = JurnalObat(
          drugId: drug[0].id,
          debet: quantity,
          kredit: 0,
          note: 'Pengeluaran obat',
          date: date.toIso8601String(),
        );

        await widget.jurnalRepository.addJurnal(jurnal).catchError((err) {
          print(err);
        });
      }

      var qty = qtyByDrugId[drug[0].id] ?? 0;
      var stock = await widget.stockRepository
          .fetchStockByDrugId(drug[0].id)
          .catchError((err) {
        print(err);
      });
      if (stock != null) {
        try {
          var newStock = Stock(
            drugId: drug[0].id,
            quantity: stock.quantity - qty,
          );
          await widget.stockRepository.updateStock(newStock);
        } catch (e) {
          print(e);
        }
      } else {
        var newStock = Stock(
          drugId: drug[0].id,
          quantity: -qty,
        );
        await widget.stockRepository.tambahStock(newStock).catchError((err) {
          print(err);
        });
      }
    }

    setState(() {
      _isLoading = false;
      _message = 'Data imported successfully.';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Data berhasil diimpor.'),
            content: Text('Klik OK untuk melanjutkan.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/drugList');
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  bool _isValidDate(int year, int month, int day) {
    try {
      DateTime date = DateTime(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } catch (e) {
      return false;
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  void _downloadExampleFile() {
    // Implementasi untuk mengunduh file contoh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Pengeluaran Obat dari DGS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              readOnly: true,
              onTap: () => _selectMonth(context),
              decoration: InputDecoration(
                labelText: 'Month (YYYY-MM)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: _selectedMonth != null
                    ? "${_selectedMonth!.year}-${_selectedMonth!.month.toString().padLeft(2, '0')}"
                    : '',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Select Excel File'),
            ),
            SizedBox(height: 16),
            _selectedFile != null
                ? Text('Selected file: ${_selectedFile!.path}')
                : Text('No file selected.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _importData,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Import Data'),
            ),
            SizedBox(height: 16),
            Text(_message, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            Text(
              'Data yang di support adalah data Excel yang di generate dari sistem DBS. Semua data tiap kolom tanggal, jika data pernah di import sebelumnya, data tidak akan diubah. Sistem hanya akan menyimpan data yang belum pernah tersimpan. Data di cari berdasarkan nama obat, hanya obat yang tersimpan di sistem yang bisa disimpan.',
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: _downloadExampleFile,
              child: Text(
                'Anda bisa download contoh yang disini -> (download)',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
