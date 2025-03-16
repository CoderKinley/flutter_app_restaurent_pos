part of 'menu_items_bloc.dart';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Product product;
  AddProduct(this.product);
}

class UpdateProduct extends ProductEvent {
  final Product product;
  UpdateProduct(this.product);
}

class DeleteProduct extends ProductEvent {
  final String id;
  DeleteProduct(this.id);
}

class DeleteAllProducts extends ProductEvent {}
