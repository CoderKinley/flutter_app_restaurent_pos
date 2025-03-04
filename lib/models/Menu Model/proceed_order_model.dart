import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';

class ProceedOrderModel extends Equatable {
  final String holdOrderId;
  final String tableNumber;
  final String customerName;
  final String phoneNumber;
  final String restaurantBranchName;
  final DateTime orderDateTime;
  final List<MenuBillModel> menuItems;

  ProceedOrderModel({
    required this.holdOrderId,
    required this.tableNumber,
    required this.customerName,
    required this.phoneNumber,
    required this.restaurantBranchName,
    required this.orderDateTime,
    required this.menuItems,
  });

  double get totalPrice {
    return menuItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  ProceedOrderModel copyWith({
    String? holdOrderId,
    String? tableNumber,
    String? customerName,
    String? phoneNumber,
    String? restaurantBranchName,
    DateTime? orderDateTime,
    List<MenuBillModel>? menuItems,
  }) {
    return ProceedOrderModel(
      holdOrderId: holdOrderId ?? this.holdOrderId,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      restaurantBranchName: restaurantBranchName ?? this.restaurantBranchName,
      orderDateTime: orderDateTime ?? this.orderDateTime,
      menuItems: menuItems ?? this.menuItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'holdOrderId': holdOrderId,
      'tableNumber': tableNumber,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'restaurantBranchName': restaurantBranchName,
      'orderDateTime': orderDateTime.toIso8601String(),
      'menuItems': jsonEncode(menuItems.map((item) => item.toMap()).toList()),
    };
  }

  factory ProceedOrderModel.fromMap(Map<String, dynamic> map) {
    return ProceedOrderModel(
      holdOrderId: map['holdOrderId'],
      tableNumber: map['tableNumber'],
      customerName: map['customerName'],
      phoneNumber: map['phoneNumber'],
      restaurantBranchName: map['restaurantBranchName'],
      orderDateTime: DateTime.parse(map['orderDateTime']),
      menuItems: List<MenuBillModel>.from(
        jsonDecode(map['menuItems']).map((item) => MenuBillModel.fromMap(item)),
      ),
    );
  }

  @override
  List<Object?> get props => [
        holdOrderId,
        tableNumber,
        customerName,
        phoneNumber,
        restaurantBranchName,
        orderDateTime,
        menuItems,
      ];
}
