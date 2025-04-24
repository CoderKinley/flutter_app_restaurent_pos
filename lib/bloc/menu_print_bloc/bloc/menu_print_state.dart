part of 'menu_print_bloc.dart';

abstract class MenuPrintState extends Equatable {
  const MenuPrintState();

  @override
  List<Object> get props => [];
}

class MenuPrintInitial extends MenuPrintState {}

class MenuPrintLoading extends MenuPrintState {}

class MenuPrintLoaded extends MenuPrintState {
  final List<Product> menuItems;
  final List<MenuPrintModel> printItems;
  final double totalAmount;

  const MenuPrintLoaded({
    required this.menuItems,
    required this.printItems,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [menuItems, printItems, totalAmount];
}
