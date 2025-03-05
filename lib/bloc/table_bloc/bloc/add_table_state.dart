part of 'add_table_bloc.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TableInitial extends TableState {}

// Loading state
class TableLoading extends TableState {}

// Loaded state (successful fetch)
class TableLoaded extends TableState {
  final List<TableNoModel> tables;

  const TableLoaded({required this.tables});

  @override
  List<Object?> get props => [tables];
}

// Error state
class TableError extends TableState {
  final String errorMessage;

  const TableError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
