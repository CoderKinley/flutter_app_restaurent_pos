import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_print_model.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
part 'menu_print_event.dart';
part 'menu_print_state.dart';

class MenuPrintBloc extends Bloc<MenuPrintEvent, MenuPrintState> {
  MenuPrintBloc() : super(MenuPrintInitial()) {
    on<LoadMenuPrintItems>(_onLoadMenuPrintItems);
    on<AddToPrint>(_onAddToPrint);
    on<RemoveFromPrint>(_onRemoveFromPrint);
    on<ReducePrintItemQuantity>(_onItemRemove);
    on<IncreasePrintItemQuantity>(_onItemAdd);
    on<UpdatePrintItemQuantity>(_onUpdatePrintItemQuantity);
    on<RemoveAllFromPrint>(_onRemoveAllFromPrint);
  }

  void _onLoadMenuPrintItems(
      LoadMenuPrintItems event, Emitter<MenuPrintState> emit) {
    emit(MenuPrintLoading());
    emit(const MenuPrintLoaded(menuItems: [], printItems: [], totalAmount: 0));
  }

  void _onAddToPrint(AddToPrint event, Emitter<MenuPrintState> emit) {
    final currentState = state as MenuPrintLoaded;
    final existingPrintItem = currentState.printItems.firstWhere(
        (item) => item.product.menuId == event.item.menuId,
        orElse: () => MenuPrintModel(
            product: event.item, customerName: event.customerName));

    List<MenuPrintModel> updatedPrint = List.from(currentState.printItems);

    if (!currentState.printItems.contains(existingPrintItem)) {
      updatedPrint.add(existingPrintItem);
    } else {
      final index = updatedPrint.indexOf(existingPrintItem);
      updatedPrint[index] =
          existingPrintItem.copyWith(quantity: existingPrintItem.quantity + 1);
    }

    double total = updatedPrint.fold(
      0.0,
      (sum, item) => (sum +
          ((double.tryParse(item.product.price) ?? 0.0) *
              item.quantity.toDouble())),
    );

    emit(MenuPrintLoaded(
      menuItems: currentState.menuItems,
      printItems: updatedPrint,
      totalAmount: total,
    ));
  }

  void _onRemoveFromPrint(RemoveFromPrint event, Emitter<MenuPrintState> emit) {
    final currentState = state as MenuPrintLoaded;
    final updatedPrint = currentState.printItems
        .where((item) => item.product.menuId != event.item.product.menuId)
        .toList();

    double total = updatedPrint.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.product.price) ?? 0.0) *
              item.quantity.toDouble()),
    );

    emit(MenuPrintLoaded(
      menuItems: currentState.menuItems,
      printItems: updatedPrint,
      totalAmount: total,
    ));
  }

  void _onItemRemove(
      ReducePrintItemQuantity event, Emitter<MenuPrintState> emit) {
    final currentState = state as MenuPrintLoaded;

    List<MenuPrintModel> updatedPrint = currentState.printItems
        .map((item) {
          if (item.product.menuId == event.item.product.menuId) {
            return item.quantity > 1
                ? item.copyWith(quantity: item.quantity - 1)
                : null;
          }
          return item;
        })
        .whereType<MenuPrintModel>()
        .toList();

    double total = updatedPrint.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.product.price) ?? 0.0) *
              item.quantity.toDouble()),
    );

    emit(MenuPrintLoaded(
      menuItems: currentState.menuItems,
      printItems: updatedPrint,
      totalAmount: total,
    ));
  }

  void _onItemAdd(
      IncreasePrintItemQuantity event, Emitter<MenuPrintState> emit) {
    final currentState = state as MenuPrintLoaded;

    List<MenuPrintModel> updatedPrint = currentState.printItems.map((item) {
      if (item.product.menuId == event.item.product.menuId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    double total = updatedPrint.fold(
      0.0,
      (sum, item) =>
          sum + ((double.tryParse(item.product.price) ?? 0.0) * item.quantity),
    );

    emit(MenuPrintLoaded(
      menuItems: currentState.menuItems,
      printItems: updatedPrint,
      totalAmount: total,
    ));
  }

  void _onUpdatePrintItemQuantity(
      UpdatePrintItemQuantity event, Emitter<MenuPrintState> emit) {
    final currentState = state as MenuPrintLoaded;

    List<MenuPrintModel> updatedPrint = List.from(event.updatedItems);

    double total = updatedPrint.fold(
      0.0,
      (sum, item) =>
          sum + ((double.tryParse(item.product.price) ?? 0.0) * item.quantity),
    );

    emit(MenuPrintLoaded(
      menuItems: currentState.menuItems,
      printItems: updatedPrint,
      totalAmount: total,
    ));
  }

  void _onRemoveAllFromPrint(
      RemoveAllFromPrint event, Emitter<MenuPrintState> emit) {
    final currentState = state as MenuPrintLoaded;
    emit(MenuPrintLoaded(
      menuItems: currentState.menuItems,
      printItems: const [],
      totalAmount: 0,
    ));
  }
}
