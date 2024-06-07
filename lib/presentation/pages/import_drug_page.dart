import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:file_picker/file_picker.dart';

class ImportDrugPage extends StatefulWidget {
  final DrugRepository drugRepository;

  ImportDrugPage({required this.drugRepository});

  @override
  _ImportDrugPageState createState() => _ImportDrugPageState();
}

class _ImportDrugPageState extends State<ImportDrugPage> {
  void _importExcel() async {
    try {
      // Pick an excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
        withData: true, // Memastikan bytes dari file di-load ke memori
      );
      if (result != null) {
        var bytes = result.files.first.bytes;
        var excel = Excel.decodeBytes(bytes!);

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;
          for (var row in sheet.rows.skip(1)) {
            // Assuming the first column is the drug name and the second column is the stock
            var name = row[0]?.value;
            var satuan = row[1]?.value;

            if (name != null && satuan != null) {
              await widget.drugRepository
                  .addDrug(name.toString(), satuan.toString());
            }
          }
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drugs imported successfully')),
        );
      }
    } catch (e) {
      // Handle error
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import drugs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Drugs'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _importExcel,
          child: Text('Import from Excel'),
        ),
      ),
    );
  }
}
