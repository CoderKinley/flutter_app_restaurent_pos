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
    _networkService.onConnectivityChanged.listen((isConnected) async {
      print('Network connectivity changed: $isConnected');
      if (isConnected) {
        final isServerAvailable = await _networkService.isServerAvailable();
        print('Server availability check: $isServerAvailable');
        if (isServerAvailable) {
          syncPendingBills();
        }
      }
    });

    // Start periodic sync
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      final isConnected = await _networkService.isConnected();
      print('Periodic sync - Network connected: $isConnected');
      if (isConnected) {
        final isServerAvailable = await _networkService.isServerAvailable();
        print('Periodic sync - Server available: $isServerAvailable');
        if (isServerAvailable) {
          syncPendingBills();
        }
      }
    });
  }

  Future<void> syncPendingBills() async {
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return;
    }
    _isSyncing = true;
    print('Starting sync of pending bills...');

    try {
      final pendingBills = await _dbHelper.getPendingBills();
      print('Found ${pendingBills.length} pending bills to sync');

      for (var bill in pendingBills) {
        try {
          final summary = BillSummaryModel.fromJson(
            jsonDecode(bill['data'] as String),
          );
          print('Processing bill: ${summary.fnbBillNo}');

          final details =
              await _dbHelper.getPendingBillDetails(summary.fnbBillNo);
          final billDetails = details
              .map((detail) => BillDetailsModel.fromJson(
                  jsonDecode(detail['data'] as String)))
              .toList();
          print(
              'Found ${billDetails.length} details for bill ${summary.fnbBillNo}');

          // Check server availability before each sync attempt
          final isServerAvailable = await _networkService.isServerAvailable();
          if (!isServerAvailable) {
            print('Server became unavailable during sync, stopping...');
            throw Exception('Server is not available');
          }

          // Submit bill summary
          print('Submitting bill summary for ${summary.fnbBillNo}');
          final summaryResponse = await http.post(
            Uri.parse('$baseUrl/api/fnb_bill_summary_legphel_eats'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(summary.toJson()),
          );

          if (summaryResponse.statusCode != 200 &&
              summaryResponse.statusCode != 201) {
            print(
                'Failed to submit bill summary: ${summaryResponse.statusCode} - ${summaryResponse.body}');
            throw Exception(
                'Failed to submit bill summary: ${summaryResponse.body}');
          }
          print('Successfully submitted bill summary');

          // Submit bill details
          for (var detail in billDetails) {
            print('Submitting bill detail for ${detail.id}');
            final detailResponse = await http.post(
              Uri.parse('$baseUrl/api/fnb_bill_details_legphel_eats'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(detail.toJson()),
            );

            if (detailResponse.statusCode != 200 &&
                detailResponse.statusCode != 201) {
              print(
                  'Failed to submit bill detail: ${detailResponse.statusCode} - ${detailResponse.body}');
              throw Exception(
                  'Failed to submit bill detail: ${detailResponse.body}');
            }
            print('Successfully submitted bill detail');
          }

          // Delete synced bill
          print('Deleting synced bill ${summary.fnbBillNo} from local storage');
          await _dbHelper.deleteSyncedBill(summary.fnbBillNo);
          print('Successfully deleted synced bill from local storage');
        } catch (e) {
          print('Error processing bill: $e');
          // Increment retry count
          await _dbHelper.incrementRetryCount(bill['fnb_bill_no'] as String);
          print('Incremented retry count for bill ${bill['fnb_bill_no']}');

          // If retry count exceeds limit, mark as failed
          if ((bill['retry_count'] as int) >= 5) {
            print(
                'Retry count exceeded for bill ${bill['fnb_bill_no']}, marking as failed');
            await _dbHelper.updateSyncStatus(
              bill['fnb_bill_no'] as String,
              'failed',
            );
          }
        }
      }
    } catch (e) {
      print('Error in syncPendingBills: $e');
    } finally {
      _isSyncing = false;
      print('Finished sync process');
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
