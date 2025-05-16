import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos_system_legphel/SQL/pending_bill_database.dart';
import 'package:pos_system_legphel/services/network_service.dart';
import 'package:pos_system_legphel/models/Bill/bill_summary_model.dart';
import 'package:pos_system_legphel/models/Bill/bill_details_model.dart';

class SyncService {
  final PendingBillDatabaseHelper _dbHelper =
      PendingBillDatabaseHelper.instance;
  final NetworkService _networkService;
  final String baseUrl;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._networkService, {required this.baseUrl}) {
    _initSync();
  }

  void _initSync() {
    // Listen to network changes
    _networkService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        syncPendingBills();
      }
    });

    // Start periodic sync
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      final isConnected = await _networkService.isConnected();
      if (isConnected) {
        syncPendingBills();
      }
    });
  }

  Future<void> syncPendingBills() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingBills = await _dbHelper.getPendingBills();

      for (var bill in pendingBills) {
        try {
          final summary = BillSummaryModel.fromJson(
            jsonDecode(bill['data'] as String),
          );

          final details =
              await _dbHelper.getPendingBillDetails(summary.fnbBillNo);
          final billDetails = details
              .map((detail) => BillDetailsModel.fromJson(
                  jsonDecode(detail['data'] as String)))
              .toList();

          // Submit bill summary
          final summaryResponse = await http.post(
            Uri.parse('$baseUrl/api/fnb_bill_summary_legphel_eats'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(summary.toJson()),
          );

          if (summaryResponse.statusCode != 200 &&
              summaryResponse.statusCode != 201) {
            throw Exception('Failed to submit bill summary');
          }

          // Submit bill details
          for (var detail in billDetails) {
            final detailResponse = await http.post(
              Uri.parse('$baseUrl/api/fnb_bill_details_legphel_eats'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(detail.toJson()),
            );

            if (detailResponse.statusCode != 200 &&
                detailResponse.statusCode != 201) {
              throw Exception('Failed to submit bill detail');
            }
          }

          // Delete synced bill
          await _dbHelper.deleteSyncedBill(summary.fnbBillNo);
        } catch (e) {
          // Increment retry count
          await _dbHelper.incrementRetryCount(bill['fnb_bill_no'] as String);

          // If retry count exceeds limit, mark as failed
          if ((bill['retry_count'] as int) >= 5) {
            await _dbHelper.updateSyncStatus(
              bill['fnb_bill_no'] as String,
              'failed',
            );
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
