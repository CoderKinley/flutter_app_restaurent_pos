part of 'add_table_bloc.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object?> get props => [];
}

// Load all tables from DB
class LoadTables extends TableEvent {}

// Add a new table
class AddTable extends TableEvent {
  final TableNoModel table;

  const AddTable(this.table);

  @override
  List<Object?> get props => [table];
}

// Update an existing table
class UpdateTable extends TableEvent {
  final TableNoModel table;

  const UpdateTable(this.table);

  @override
  List<Object?> get props => [table];
}

// Delete a table
class DeleteTable extends TableEvent {
  final String tableNumber;

  const DeleteTable(this.tableNumber);

  @override
  List<Object?> get props => [tableNumber];
}
