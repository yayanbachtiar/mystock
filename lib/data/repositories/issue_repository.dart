// issue_repository.dart
import 'package:mystok/data/models/issue_model.dart';
import 'package:pocketbase/pocketbase.dart';

class IssueRepository {
  final PocketBase client;

  IssueRepository(this.client);

  Future<Issue?> fetchIssueByDrugAndDate(String drugId, DateTime date) async {
    final response = await client.collection('issues').getList(
          filter:
              '(drug_id="$drugId" && tanggal_only="${date.toString().substring(0, 10)}")',
        );

    if (response.items.isNotEmpty) {
      return response.items
          .map((record) => Issue.fromJson(record.toJson()))
          .first;
    }
    return null;
  }

  Future<void> tambahIssue(Issue issue) async {
    await client.collection('issues').create(body: issue.toJson());
  }
}

// stock_repository.dart
