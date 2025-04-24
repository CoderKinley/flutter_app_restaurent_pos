part of 'menu_print_bloc.dart';

abstract class MenuPrintEvent extends Equatable {
  const MenuPrintEvent();

  @override
  List<Object> get props => [];
}

class LoadMenuPrintItems extends MenuPrintEvent {
  const LoadMenuPrintItems();
}

class AddToPrint extends MenuPrintEvent {
  final MenuModel item;
  final String customerName;

  const AddToPrint(
    this.item,
    this.customerName,
  );

  @override
  List<Object> get props => [item, customerName];
}

class RemoveFromPrint extends MenuPrintEvent {
  final MenuPrintModel item;

  const RemoveFromPrint({required this.item});

  @override
  List<Object> get props => [item];
}

class ReducePrintItemQuantity extends MenuPrintEvent {
  final MenuPrintModel item;

  const ReducePrintItemQuantity({required this.item});

  @override
  List<Object> get props => [item];
}

class IncreasePrintItemQuantity extends MenuPrintEvent {
  final MenuPrintModel item;

  const IncreasePrintItemQuantity({required this.item});

  @override
  List<Object> get props => [item];
}

class UpdatePrintItemQuantity extends MenuPrintEvent {
  final List<MenuPrintModel> updatedItems;

  const UpdatePrintItemQuantity({required this.updatedItems});

  @override
  List<Object> get props => [updatedItems];
}

class RemoveAllFromPrint extends MenuPrintEvent {
  const RemoveAllFromPrint();
}
