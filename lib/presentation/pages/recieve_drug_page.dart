import 'package:flutter/material.dart';
import 'package:mystok/data/repositories/drug_repository.dart';

class ReceiveDrugPage extends StatefulWidget {
  final DrugRepository drugRepository;

  ReceiveDrugPage({required this.drugRepository});

  @override
  _ReceiveDrugPageState createState() => _ReceiveDrugPageState();
}

class _ReceiveDrugPageState extends State<ReceiveDrugPage> {
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();

  void _receiveDrug() async {
    try {
      await widget.drugRepository.addDrug(
        _nameController.text,
        int.parse(_stockController.text),
      );
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drug received successfully')),
      );
      // Clear input fields
      _nameController.clear();
      _stockController.clear();
    } catch (e) {
      // Handle error
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to receive drug')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receive Drug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Drug Name'),
            ),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _receiveDrug,
              child: Text('Receive'),
            ),
          ],
        ),
      ),
    );
  }
}
