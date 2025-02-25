// Stores the receipt model for the receipt model class
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';

class MenuReceipt {
  final String id;
  final String userId;
  final String tableNo;
  final List<Product> items;
  final double subtotal;
  final double gst;
  final int totalQuantity;
  final DateTime dateTime;
  final double totalAmount;
  final PaymentMode paymentMode;
  final OrderType orderType;

  MenuReceipt({
    required this.id,
    required this.userId,
    required this.tableNo,
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.totalQuantity,
    required this.dateTime,
    required this.totalAmount,
    required this.paymentMode,
    required this.orderType,
  });
}

enum PaymentMode { cash, scanPay, creditCard }

enum OrderType { delivery, dineIn, takeAway }
