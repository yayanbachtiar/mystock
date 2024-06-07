import 'package:flutter/material.dart';
import 'package:mystok/data/repositories/drug_repository.dart';

class AdjustDrugPage extends StatefulWidget {
  final DrugRepository drugRepository;

  AdjustDrugPage({required this.drugRepository});

  @override
  _AdjustDrugPageState createState() => _AdjustDrugPageState();
}

class _AdjustDrugPageState extends State<AdjustDrugPage> {
  final _idController = TextEditingController();
  final _stockController = TextEditingController();

  void _adjustDrug() async {
    try {
      await widget.drugRepository.adjustDrug(
        _idController.text,
        int.parse(_stockController.text),
      );
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drug adjusted successfully')),
      );
      // Clear input fields
      _idController.clear();
      _stockController.clear();
    } catch (e) {
      // Handle error
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to adjust drug')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adjust Drug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Drug ID'),
            ),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'New Stock'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _adjustDrug,
              child: Text('Adjust'),
            ),
          ],
        ),
      ),
    );
  }
}
