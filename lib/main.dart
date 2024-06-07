import 'package:flutter/material.dart';
import 'package:mystok/presentation/pages/recieve_drug_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:mystok/data/repositories/auth_repository.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/presentation/pages/login_page.dart';
import 'package:mystok/presentation/pages/drug_list_page.dart';
import 'package:mystok/presentation/pages/import_drug_page.dart';
import 'package:mystok/presentation/pages/adjust_drug_page.dart';
import 'package:mystok/presentation/pages/report_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PocketBase pb = PocketBase('http://10.0.0.102:8080');
  late final AuthRepository authRepository;
  late final DrugRepository drugRepository;

  MyApp() {
    authRepository = AuthRepository(pb);
    drugRepository = DrugRepository(pb);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Obat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(authRepository: authRepository),
      routes: {
        '/login': (context) => LoginPage(authRepository: authRepository),
        '/drugList': (context) => DrugListPage(
            drugRepository: drugRepository, authRepository: authRepository),
        '/receiveDrug': (context) =>
            ReceiveDrugPage(drugRepository: drugRepository),
        '/importDrug': (context) =>
            ImportDrugPage(drugRepository: drugRepository),
        '/adjustDrug': (context) =>
            AdjustDrugPage(drugRepository: drugRepository),
        '/report': (context) => ReportPage(drugRepository: drugRepository),
      },
    );
  }
}
