import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';

class MenuBillModel {
  final Product product;
  int quantity;

  MenuBillModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price.toDouble() * quantity.toDouble();

  MenuBillModel copyWith({
    Product? product,
    int? quantity,
  }) {
    return MenuBillModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
