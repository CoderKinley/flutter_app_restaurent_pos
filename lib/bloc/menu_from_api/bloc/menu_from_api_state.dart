part of 'menu_from_api_bloc.dart';

abstract class MenuApiState extends Equatable {
  const MenuApiState();

  @override
  List<Object?> get props => [];
}

class MenuApiInitial extends MenuApiState {}

class MenuApiLoading extends MenuApiState {}

class MenuApiLoaded extends MenuApiState {
  final List<MenuModel> menuItems;

  const MenuApiLoaded(this.menuItems);

  @override
  List<Object?> get props => [menuItems];
}

class MenuApiError extends MenuApiState {
  final String message;

  const MenuApiError(this.message);

  @override
  List<Object?> get props => [message];
}

class MenuApiItemAdded extends MenuApiState {}

class MenuApiItemUpdated extends MenuApiState {}

class MenuApiItemDeleted extends MenuApiState {}
