import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuInitial()) {
    on<LoadMenuItems>(_onLoadMenuItems);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ReduceCartItemQuantity>(_onItemRemove);
    on<IncreaseCartItemQuantity>(_onItemAdd);
  }

  void _onLoadMenuItems(LoadMenuItems event, Emitter<MenuState> emit) {
    emit(MenuLoading());

    // final currentState = state as MenuLoaded;
    emit(MenuLoaded(menuItems: [], cartItems: [], totalAmount: 0));
  }

  void _onAddToCart(AddToCart event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;
    final existingCartItem = currentState.cartItems.firstWhere(
        (item) => item.product.id == event.item.id,
        orElse: () => MenuBillModel(product: event.item));

    List<MenuBillModel> updatedCart = List.from(currentState.cartItems);

    if (!currentState.cartItems.contains(existingCartItem)) {
      updatedCart.add(existingCartItem);
    } else {
      final index = updatedCart.indexOf(existingCartItem);
      updatedCart[index].quantity++;
    }

    double total = updatedCart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;
    final updatedCart = currentState.cartItems
        .where((item) => item.product.id != event.item.product.id)
        .toList();

    double total = updatedCart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));

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
          if (item.product.id == event.item.product.id) {
            return item.quantity > 1
                ? item.copyWith(quantity: item.quantity - 1) // Reduce quantity
                : null; // Remove item if quantity is 1
          }
          return item;
        })
        .whereType<MenuBillModel>()
        .toList(); // Remove null items

    double total = updatedCart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }

  void _onItemAdd(IncreaseCartItemQuantity event, Emitter<MenuState> emit) {
    final currentState = state as MenuLoaded;

    List<MenuBillModel> updatedCart = currentState.cartItems.map((item) {
      if (item.product.id == event.item.product.id) {
        return item.copyWith(quantity: item.quantity + 1); // Increase quantity
      }
      return item;
    }).toList();

    double total = updatedCart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));

    emit(MenuLoaded(
      menuItems: currentState.menuItems,
      cartItems: updatedCart,
      totalAmount: total,
    ));
  }
}
