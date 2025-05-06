import 'dart:convert';
import 'package:equatable/equatable.dart'; // Import Equatable
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';

class HoldOrderModel extends Equatable {
  // Extend Equatable
  final String holdOrderId;
  final String tableNumber;
  final String customerName;
  final String orderNumber;
  final String customerContact;
  final DateTime orderDateTime;
  final List<MenuBillModel> menuItems;

  const HoldOrderModel({
    required this.holdOrderId,
    required this.orderNumber,
    required this.tableNumber,
    required this.customerContact,
    required this.customerName,
    required this.orderDateTime,
    required this.menuItems,
  });

  double get totalPrice {
    return menuItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  HoldOrderModel copyWith({
    String? holdOrderId,
    String? tableNumber,
    String? customerName,
    String? orderNumber,
    DateTime? orderDateTime,
    String? customerContact,
    List<MenuBillModel>? menuItems,
  }) {
    return HoldOrderModel(
      holdOrderId: holdOrderId ?? this.holdOrderId,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      orderNumber: orderNumber ?? this.orderNumber,
      customerContact: customerContact ?? this.customerContact,
      orderDateTime: orderDateTime ?? this.orderDateTime,
      menuItems: menuItems ?? this.menuItems,
    );
  }

  // Convert HoldOrderModel to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'holdOrderId': holdOrderId,
      'tableNumber': tableNumber,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'customerContact': customerContact,
      'orderDateTime': orderDateTime.toIso8601String(),
      'menuItems': jsonEncode(menuItems
          .map((item) => item.toMap())
          .toList()), // Convert to JSON string
    };
  }

  // Convert map (from database) to HoldOrderModel
  factory HoldOrderModel.fromMap(Map<String, dynamic> map) {
    return HoldOrderModel(
      holdOrderId: map['holdOrderId'],
      tableNumber: map['tableNumber'],
      orderNumber: map['orderNumber'],
      customerName: map['customerName'],
      customerContact: map['customerContact'],
      orderDateTime: DateTime.parse(map['orderDateTime']),
      menuItems: List<MenuBillModel>.from(
        jsonDecode(map['menuItems']).map((item) => MenuBillModel.fromMap(item)),
      ),
    );
  }

  // Equatable props (ensure all fields are included for proper comparison)
  @override
  List<Object?> get props => [
        holdOrderId,
        tableNumber,
        orderNumber,
        customerName,
        orderDateTime,
        menuItems,
      ];
}
