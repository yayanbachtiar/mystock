import 'package:flutter/material.dart';
import 'package:mystok/common/config_manager.dart';
import 'package:mystok/data/repositories/issue_repository.dart';
import 'package:mystok/data/repositories/jurnal_repository.dart';
import 'package:mystok/data/repositories/stok_repository.dart';
import 'package:mystok/presentation/pages/api_config_page.dart';
import 'package:mystok/presentation/pages/issues_drug_page.dart';
import 'package:mystok/presentation/pages/recieve_drug_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:mystok/data/repositories/auth_repository.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/presentation/pages/login_page.dart';
import 'package:mystok/presentation/pages/drug_list_page.dart';
import 'package:mystok/presentation/pages/import_drug_page.dart';
import 'package:mystok/presentation/pages/adjust_drug_page.dart';
import 'package:mystok/presentation/pages/report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? apiUrl = await ConfigManager.getApiUrl();
  print(apiUrl);
  if (apiUrl == null) {
    // Redirect to API configuration page if API URL is not set
    runApp(ApiConfigApp());
  } else {
    // Initialize PocketBase client with the API URL
    final PocketBase pb = PocketBase(apiUrl);

    runApp(MyApp(pb));
  }
}

class ApiConfigApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ApiConfigPage(),
    );
  }
}

class MyApp extends StatelessWidget {
  late final AuthRepository authRepository;
  late final DrugRepository drugRepository;
  late final IssueRepository issueRepository;
  late final StockRepository stockRepository;
  late final JurnalRepository jurnalRepository;

  MyApp(PocketBase pb, {super.key}) {
    authRepository = AuthRepository(pb);
    drugRepository = DrugRepository(pb);
    stockRepository = StockRepository(pb);
    issueRepository = IssueRepository(pb);
    jurnalRepository = JurnalRepository(pb);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/report': (context) => ReportPage(
              drugRepository: drugRepository,
              jurnalRepository: jurnalRepository,
            ),
        '/issueDrug': (context) => IssuesDrugPage(
              drugRepository: drugRepository,
              issueRepository: issueRepository,
              stockRepository: stockRepository,
              jurnalRepository: jurnalRepository,
            ),
      },
    );
  }
}
