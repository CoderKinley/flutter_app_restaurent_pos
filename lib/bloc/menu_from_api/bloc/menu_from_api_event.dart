part of 'menu_from_api_bloc.dart';

abstract class MenuApiEvent extends Equatable {
  const MenuApiEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuFromDB extends MenuApiEvent {}

class FetchMenuApi extends MenuApiEvent {}

class FetchMenuFromApi extends MenuApiEvent {}

class AddMenuApiItem extends MenuApiEvent {
  final MenuModel menuItem;

  const AddMenuApiItem(this.menuItem);

  @override
  List<Object?> get props => [menuItem];
}

class RemoveMenuApiItem extends MenuApiEvent {
  final String menuId;

  const RemoveMenuApiItem(this.menuId);

  @override
  List<Object?> get props => [menuId];
}

class UpdateMenuApiItem extends MenuApiEvent {
  final MenuModel menuItem;

  const UpdateMenuApiItem(this.menuItem);

  @override
  List<Object?> get props => [menuItem];
}
