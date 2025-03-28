import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';

class CustomerInfoModel extends Equatable {
  final String orderId;
  final String tableNumber;
  final String customerName;
  final String customerContact;
  final DateTime orderDateTime;
  final List<MenuBillModel> orderedItems;

  const CustomerInfoModel({
    required this.orderId,
    required this.tableNumber,
    required this.customerName,
    required this.customerContact,
    required this.orderDateTime,
    required this.orderedItems,
  });

  CustomerInfoModel copyWith({
    String? orderId,
    String? tableNumber,
    String? customerName,
    String? customerContact,
    DateTime? orderDateTime,
    List<MenuBillModel>? orderedItems,
  }) {
    return CustomerInfoModel(
      orderId: orderId ?? this.orderId,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      orderDateTime: orderDateTime ?? this.orderDateTime,
      orderedItems: orderedItems ?? this.orderedItems,
    );
  }

  // Convert CustomerInfoModel to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'tableNumber': tableNumber,
      'customerName': customerName,
      'customerContact': customerContact,
      'orderDateTime': orderDateTime.toIso8601String(),
      'orderedItems': jsonEncode(
        orderedItems.map((item) => item.toMap()).toList(),
      ),
    };
  }

  // Convert map (from database) to CustomerInfoModel
  factory CustomerInfoModel.fromMap(Map<String, dynamic> map) {
    return CustomerInfoModel(
      orderId: map['orderId'],
      tableNumber: map['tableNumber'],
      customerName: map['customerName'],
      customerContact: map['customerContact'],
      orderDateTime: DateTime.parse(map['orderDateTime']),
      orderedItems: List<MenuBillModel>.from(
        jsonDecode(map['orderedItems'])
            .map((item) => MenuBillModel.fromMap(item)),
      ),
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        tableNumber,
        customerName,
        customerContact,
        orderDateTime,
        orderedItems,
      ];
}
