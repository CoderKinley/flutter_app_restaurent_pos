import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/table_bloc/bloc/add_table_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/add_table_page.dart';

class AddNewTable extends StatefulWidget {
  const AddNewTable({super.key});

  @override
  State<AddNewTable> createState() => _AddNewTableState();
}

class _AddNewTableState extends State<AddNewTable> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content of the screen
        BlocBuilder<TableBloc, TableState>(
          builder: (context, state) {
            if (state is TableLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is TableLoaded) {
              return ListView.builder(
                itemCount: state.tables.length,
                itemBuilder: (context, index) {
                  final table = state.tables[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to a new page to edit/update table details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTablePage(
                                tableModel: table,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text("Table ${table.tableNumber}"),
                            subtitle: Text(
                              table.tableName != null &&
                                      table.tableName!.isNotEmpty
                                  ? table.tableName!
                                  : "No name assigned",
                              style: const TextStyle(color: Colors.green),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                context
                                    .read<TableBloc>()
                                    .add(DeleteTable(table.tableNumber));
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ),
                        ),
                      ),
                      // Divider added here between list items
                      const Divider(),
                    ],
                  );
                },
              );
            }
            return Container();
          },
        ),

        // Custom Floating Action Button -------------------------------------->
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const AddTablePage();
                },
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 3, 27, 48),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}
