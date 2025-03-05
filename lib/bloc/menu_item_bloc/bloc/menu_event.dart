part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {}

class LoadMenuItems extends MenuEvent {
  @override
  List<Object> get props => [];
}

class AddToCart extends MenuEvent {
  final Product item;
  AddToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends MenuEvent {
  final MenuBillModel item;
  RemoveFromCart(this.item);

  @override
  List<Object> get props => [item];
}

class ReduceCartItemQuantity extends MenuEvent {
  final MenuBillModel item;

  ReduceCartItemQuantity(this.item);

  @override
  List<Object> get props => [item];
}

class IncreaseCartItemQuantity extends MenuEvent {
  final MenuBillModel item;

  IncreaseCartItemQuantity(this.item);

  @override
  List<Object> get props => [];
}

class UpdateCartItemQuantity extends MenuEvent {
  final List<MenuBillModel> updatedItems;

  UpdateCartItemQuantity(this.updatedItems);

  @override
  List<Object?> get props => [updatedItems];
}

class RemoveAllFromCart extends MenuEvent {
  @override
  List<Object?> get props => [];
}
