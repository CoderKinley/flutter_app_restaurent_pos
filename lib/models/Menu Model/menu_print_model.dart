import 'package:pos_system_legphel/models/others/new_menu_model.dart';

class MenuPrintModel {
  final MenuModel product;
  String? menuId;
  String? customerName;
  int quantity;

  MenuPrintModel({
    required this.product,
    this.menuId,
    this.customerName,
    this.quantity = 1,
  });

  double get totalPrice {
    double parsedPrice = double.tryParse(product.price) ?? 0.0;
    return parsedPrice * quantity.toDouble();
  }

  MenuPrintModel copyWith({
    MenuModel? product,
    int? quantity,
  }) {
    return MenuPrintModel(
      product: product ?? this.product,
      menuId: menuId ?? menuId,
      customerName: customerName ?? customerName,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory MenuPrintModel.fromMap(Map<String, dynamic> map) {
    return MenuPrintModel(
      product: MenuModel.fromMap(map['product']),
      quantity: map['quantity'],
      menuId: map['menuId'],
      customerName: map['customerName'],
    );
  }
}
