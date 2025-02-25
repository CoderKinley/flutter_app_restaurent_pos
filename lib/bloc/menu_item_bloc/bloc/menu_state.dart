part of 'menu_bloc.dart';

abstract class MenuState {}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Product> menuItems;
  final List<MenuBillModel> cartItems;
  final double totalAmount;

  MenuLoaded({
    required this.menuItems,
    required this.cartItems,
    required this.totalAmount,
  });
}
