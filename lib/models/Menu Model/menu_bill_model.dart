import 'package:pos_system_legphel/models/new_menu_model.dart';

class MenuBillModel {
  final MenuModel product;
  int quantity;
  String? menuId;
  String? customerName;
  String? CustomerContact;
  String? TableNo;

  MenuBillModel({
    required this.product,
    this.quantity = 1,
    this.menuId,
    this.CustomerContact,
    this.TableNo,
    this.customerName,
  });

  double get totalPrice {
    double parsedPrice = double.tryParse(product.price) ?? 0.0;
    return parsedPrice * quantity.toDouble();
  }

  MenuBillModel copyWith({
    MenuModel? product,
    int? quantity,
  }) {
    return MenuBillModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      menuId: menuId ?? this.menuId,
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
    );
  }
}
