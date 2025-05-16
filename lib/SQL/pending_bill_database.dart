import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:pos_system_legphel/models/Bill/bill_summary_model.dart';
import 'package:pos_system_legphel/models/Bill/bill_details_model.dart';

class PendingBillDatabaseHelper {
  static final PendingBillDatabaseHelper instance =
      PendingBillDatabaseHelper._init();
  static Database? _database;

  PendingBillDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pending_bills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_bill_summaries (
        fnb_bill_no TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_bill_details (
        id TEXT PRIMARY KEY,
        fnb_bill_no TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        FOREIGN KEY (fnb_bill_no) REFERENCES pending_bill_summaries (fnb_bill_no)
      )
    ''');
  }

  Future<void> insertPendingBill(
    BillSummaryModel summary,
    List<BillDetailsModel> details,
  ) async {
    final db = await database;
    final batch = db.batch();

    // Insert summary
    batch.insert('pending_bill_summaries', {
      'fnb_bill_no': summary.fnbBillNo,
      'data': jsonEncode(summary.toJson()),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'sync_status': 'pending',
      'retry_count': 0,
    });

    // Insert details
    for (var detail in details) {
      batch.insert('pending_bill_details', {
        'id': detail.id,
        'fnb_bill_no': detail.fnbBillNo,
        'data': jsonEncode(detail.toJson()),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'sync_status': 'pending',
        'retry_count': 0,
      });
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getPendingBills() async {
    final db = await database;
    return await db.query(
      'pending_bill_summaries',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getPendingBillDetails(
      String fnbBillNo) async {
    final db = await database;
    return await db.query(
      'pending_bill_details',
      where: 'fnb_bill_no = ? AND sync_status = ?',
      whereArgs: [fnbBillNo, 'pending'],
    );
  }

  Future<void> updateSyncStatus(String fnbBillNo, String status) async {
    final db = await database;
    final batch = db.batch();

    batch.update(
      'pending_bill_summaries',
      {'sync_status': status},
      where: 'fnb_bill_no = ?',
      whereArgs: [fnbBillNo],
    );

    batch.update(
      'pending_bill_details',
      {'sync_status': status},
      where: 'fnb_bill_no = ?',
      whereArgs: [fnbBillNo],
    );

    await batch.commit();
  }

  Future<void> incrementRetryCount(String fnbBillNo) async {
    final db = await database;
    final batch = db.batch();

    batch.rawUpdate(
      'UPDATE pending_bill_summaries SET retry_count = retry_count + 1 WHERE fnb_bill_no = ?',
      [fnbBillNo],
    );

    batch.rawUpdate(
      'UPDATE pending_bill_details SET retry_count = retry_count + 1 WHERE fnb_bill_no = ?',
      [fnbBillNo],
    );

    await batch.commit();
  }

  Future<void> deleteSyncedBill(String fnbBillNo) async {
    final db = await database;
    final batch = db.batch();

    batch.delete(
      'pending_bill_details',
      where: 'fnb_bill_no = ?',
      whereArgs: [fnbBillNo],
    );

    batch.delete(
      'pending_bill_summaries',
      where: 'fnb_bill_no = ?',
      whereArgs: [fnbBillNo],
    );

    await batch.commit();
  }
}
