import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/table_bloc/bloc/add_table_bloc.dart';
import 'package:pos_system_legphel/models/others/table_no_model.dart';

class AddTablePage extends StatefulWidget {
  final TableNoModel? tableModel;
  const AddTablePage({
    super.key,
    this.tableModel,
  });

  @override
  State<AddTablePage> createState() => _AddTablePageState();
}

class _AddTablePageState extends State<AddTablePage> {
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _tableNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tableModel != null) {
      _tableNameController.text = widget.tableModel!.tableName ?? '';
      _tableNumberController.text = widget.tableModel!.tableNumber;
    }
  }

  void _addTable() {
    final tableNumber = _tableNumberController.text.trim();
    final tableName = _tableNameController.text.trim();

    if (tableNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Table Number is required")),
      );
      return;
    }

    final newTable =
        TableNoModel(tableNumber: tableNumber, tableName: tableName);

    context.read<TableBloc>().add(AddTable(newTable));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Table Added Successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tableModel == null ? "Add New Table" : "Edit Table",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _tableNumberController,
                decoration: const InputDecoration(
                  labelText: "Table Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tableNameController,
                decoration: const InputDecoration(
                  labelText: "Table Name (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _addTable,
                    child: Text(
                      widget.tableModel == null ? "Add Table" : "Edit Table",
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TableBloc>().add(DeleteTable(
                          widget.tableModel!.tableNumber.toString()));
                      Navigator.pop(context);
                    },
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _tableNameController.dispose();
    super.dispose();
  }
}
