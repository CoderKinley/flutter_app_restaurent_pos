import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/SQL/table_database_helper.dart';
import 'package:pos_system_legphel/models/others/table_no_model.dart';

part 'add_table_event.dart';
part 'add_table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableDatabaseHelper _tableDatabase = TableDatabaseHelper.instance;

  TableBloc() : super(TableInitial()) {
    on<LoadTables>(_onLoadTables);
    on<AddTable>(_onAddTable);
    on<UpdateTable>(_onUpdateTable);
    on<DeleteTable>(_onDeleteTable);
  }

  // Load Tables from Database
  void _onLoadTables(LoadTables event, Emitter<TableState> emit) async {
    emit(TableLoading());
    try {
      final tables = await _tableDatabase.fetchTables();
      emit(TableLoaded(tables: tables));
    } catch (e) {
      emit(TableError(errorMessage: "Failed to load tables: $e"));
    }
  }

  // Add a new Table
  void _onAddTable(AddTable event, Emitter<TableState> emit) async {
    try {
      await _tableDatabase.insertTable(event.table);
      add(LoadTables());
    } catch (e) {
      emit(TableError(errorMessage: "Failed to add table: $e"));
    }
  }

  // Update an existing Table
  void _onUpdateTable(UpdateTable event, Emitter<TableState> emit) async {
    try {
      await _tableDatabase.updateTable(event.table);
      add(LoadTables());
    } catch (e) {
      emit(TableError(errorMessage: "Failed to update table: $e"));
    }
  }

  // Delete a Table
  void _onDeleteTable(DeleteTable event, Emitter<TableState> emit) async {
    try {
      await _tableDatabase.deleteTable(event.tableNumber);
      add(LoadTables());
    } catch (e) {
      emit(TableError(errorMessage: "Failed to delete table: $e"));
    }
  }
}
