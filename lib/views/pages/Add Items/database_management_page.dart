import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseManagementPage extends StatefulWidget {
  const DatabaseManagementPage({super.key});

  @override
  State<DatabaseManagementPage> createState() => _DatabaseManagementPageState();
}

class _DatabaseManagementPageState extends State<DatabaseManagementPage> {
  List<FileSystemEntity> databaseFiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDatabases();
  }

  Future<void> _loadDatabases() async {
    setState(() => isLoading = true);
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      print('App directory: ${appDir.path}');

      // Check multiple possible database locations
      final possiblePaths = [
        path.join(appDir.path, 'databases'),
        appDir.path,
        path.join(appDir.path, '..', 'databases'),
        path.join(appDir.path, '..', 'app_flutter'),
        path.join(appDir.path, '..', 'app_flutter', 'databases'),
      ];

      List<FileSystemEntity> allFiles = [];

      for (var dbPath in possiblePaths) {
        final dir = Directory(dbPath);
        if (await dir.exists()) {
          print('Checking directory: $dbPath');
          final files = await dir.list().toList();
          allFiles.addAll(files);
        }
      }

      setState(() {
        databaseFiles = allFiles.where((file) {
          final ext = path.extension(file.path).toLowerCase();
          final isDb = ext == '.db' || ext == '.sqlite';
          if (isDb) {
            print('Found database: ${file.path}');
          }
          return isDb;
        }).toList();
      });

      if (databaseFiles.isEmpty) {
        print('No databases found in any of the checked locations');
      }
    } catch (e) {
      print('Error loading databases: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading databases: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _exportToExcel(FileSystemEntity dbFile) async {
    try {
      setState(() => isLoading = true);

      // Request storage permission
      if (await Permission.manageExternalStorage.request().isGranted) {
        // Open the database
        final database = await openDatabase(dbFile.path);

        // Get all tables
        final tables = await database.query('sqlite_master',
            where: 'type = ?', whereArgs: ['table'], columns: ['name']);

        // Create Excel workbook
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Data'];

        // For each table, export data
        for (var table in tables) {
          final tableName = table['name'] as String;
          if (tableName == 'sqlite_sequence' || tableName == 'android_metadata')
            continue;

          // Get table data
          final data = await database.query(tableName);
          if (data.isEmpty) continue;

          // Add table name as a header
          sheetObject.appendRow([tableName.toUpperCase()]);

          // Add column headers
          final headers = data.first.keys.toList();
          sheetObject.appendRow(headers);

          // Add data rows
          for (var row in data) {
            List<dynamic> rowData = [];
            for (var header in headers) {
              rowData.add(row[header]?.toString() ?? '');
            }
            sheetObject.appendRow(rowData);
          }

          // Add empty row between tables
          sheetObject.appendRow([]);
        }

        // Save Excel file
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName =
            '${path.basenameWithoutExtension(dbFile.path)}_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final filePath = path.join(downloadsDir.path, fileName);

        final fileBytes = excel.encode();
        if (fileBytes != null) {
          await File(filePath).writeAsBytes(fileBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to: $filePath')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting database: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : databaseFiles.isEmpty
              ? const Center(child: Text('No databases found'))
              : ListView.builder(
                  itemCount: databaseFiles.length,
                  itemBuilder: (context, index) {
                    final dbFile = databaseFiles[index];
                    return ListTile(
                      leading: const Icon(Icons.storage_rounded),
                      title: Text(path.basename(dbFile.path)),
                      subtitle: Text(
                        'Size: ${(dbFile.statSync().size / 1024).toStringAsFixed(2)} KB',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _exportToExcel(dbFile),
                        tooltip: 'Export to Excel',
                      ),
                    );
                  },
                ),
    );
  }
}
