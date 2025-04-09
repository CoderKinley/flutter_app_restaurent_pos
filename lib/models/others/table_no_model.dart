import 'package:equatable/equatable.dart';

class TableNoModel extends Equatable {
  final String? tableName;
  final String tableNumber;

  const TableNoModel({
    this.tableName,
    required this.tableNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'tableName': tableName,
      'tableNumber': tableNumber,
    };
  }

  factory TableNoModel.fromMap(Map<String, dynamic> map) {
    return TableNoModel(
      tableName: map['tableName'],
      tableNumber: map['tableNumber'] ?? '',
    );
  }

  TableNoModel copyWith({
    String? tableName,
    String? tableNumber,
  }) {
    return TableNoModel(
      tableName: tableName ?? this.tableName,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }

  @override
  List<Object?> get props => [tableName, tableNumber];

  @override
  String toString() {
    return 'TableNoModel(tableName: $tableName, tableNumber: $tableNumber)';
  }
}
