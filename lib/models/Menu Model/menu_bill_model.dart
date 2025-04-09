import 'package:pos_system_legphel/models/others/new_menu_model.dart';

class MenuBillModel {
  final MenuModel product;
  int quantity;
  String? menuId;
  String? customerName;
  String? customerContact;
  String? tableNo;

  MenuBillModel({
    required this.product,
    this.quantity = 1,
    this.menuId,
    this.customerContact,
    this.tableNo,
    this.customerName,
  });

  double get totalPrice {
    double parsedPrice = double.tryParse(product.price) ?? 0.0;
    return parsedPrice * quantity.toDouble();
  }

  MenuBillModel copyWith({
    MenuModel? product,
    int? quantity,
    String? customerName,
  }) {
    return MenuBillModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      menuId: menuId ?? menuId,
      customerName: customerName ?? this.customerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory MenuBillModel.fromMap(Map<String, dynamic> map) {
    return MenuBillModel(
      product: MenuModel.fromMap(map['product']),
      quantity: map['quantity'],
      menuId: map['menuId'],
      customerName: map['customerName'],
    );
  }
}
