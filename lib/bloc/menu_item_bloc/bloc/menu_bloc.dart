import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuInitial()) {
    on<LoadMenuItems>(_onLoadMenuItems);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ReduceCartItemQuantity>(_onItemRemove);
    on<IncreaseCartItemQuantity>(_onItemAdd);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveAllFromCart>(_onRemoveAllFromCart);
  }

  void _onLoadMenuItems(LoadMenuItems event, Emitter<MenuState> emit) {
    emit(MenuLoading());
    emit(MenuLoaded(menuItems: [], cartItems: [], totalAmount: 0));
  }

  void _onAddToCart(AddToCart event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;
    final existingCartItem = currentState.cartItems.firstWhere(
        (item) => item.product.menuId == event.item.menuId,
        orElse: () => MenuBillModel(
            product: event.item, customerName: event.customerName));

    List<MenuBillModel> updatedCart = List.from(currentState.cartItems);

    if (!currentState.cartItems.contains(existingCartItem)) {
      updatedCart.add(existingCartItem);
    } else {
      final index = updatedCart.indexOf(existingCartItem);
      updatedCart[index] =
          existingCartItem.copyWith(quantity: existingCartItem.quantity + 1);
    }

    double total = updatedCart.fold(
      0.0,
      (sum, item) => (sum +
          ((double.tryParse(item.product.price) ?? 0.0) *
              item.quantity.toDouble())),
    );

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;
    final updatedCart = currentState.cartItems
        .where((item) => item.product.menuId != event.item.product.menuId)
        .toList();

    double total = updatedCart.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.product.price) ?? 0.0) *
              item.quantity.toDouble()),
    );

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onItemRemove(ReduceCartItemQuantity event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;

    List<MenuBillModel> updatedCart = currentState.cartItems
        .map((item) {
          if (item.product.menuId == event.item.product.menuId) {
            return item.quantity > 1
                ? item.copyWith(quantity: item.quantity - 1)
                : null;
          }
          return item;
        })
        .whereType<MenuBillModel>()
        .toList();

    double total = updatedCart.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.product.price) ?? 0.0) *
              item.quantity.toDouble()),
    );

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onItemAdd(IncreaseCartItemQuantity event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;

    List<MenuBillModel> updatedCart = currentState.cartItems.map((item) {
      if (item.product.menuId == event.item.product.menuId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    double total = updatedCart.fold(
      0.0,
      (sum, item) =>
          sum + ((double.tryParse(item.product.price) ?? 0.0) * item.quantity),
    );

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onUpdateCartItemQuantity(
      UpdateCartItemQuantity event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;

    List<MenuBillModel> updatedCart = List.from(event.updatedItems);

    double total = updatedCart.fold(
      0.0,
      (sum, item) =>
          sum + ((double.tryParse(item.product.price) ?? 0.0) * item.quantity),
    );

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onRemoveAllFromCart(RemoveAllFromCart event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;
    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: [],
      totalAmount: 0,
    ));
  }
}
