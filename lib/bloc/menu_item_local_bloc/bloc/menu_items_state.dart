part of 'menu_items_bloc.dart';

abstract class ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}
