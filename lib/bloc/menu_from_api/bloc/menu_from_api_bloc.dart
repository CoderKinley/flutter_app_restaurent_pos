import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/data/repositories/menu_repository.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';

part 'menu_from_api_event.dart';
part 'menu_from_api_state.dart';

class MenuApiBloc extends Bloc<MenuApiEvent, MenuApiState> {
  final MenuRepository repository;

  MenuApiBloc(this.repository) : super(MenuApiInitial()) {
    on<FetchMenuApi>(_onFetchMenuApi);
    on<FetchMenuFromApi>(_onFetchMenuFromApi);
    on<AddMenuApiItem>(_onAddMenuApiItem);
    on<RemoveMenuApiItem>(_onRemoveMenuApiItem);
    on<UpdateMenuApiItem>(_onUpdateMenuApiItem);
  }

  Future<void> _onFetchMenuApi(
      FetchMenuApi event, Emitter<MenuApiState> emit) async {
    emit(MenuApiLoading());
    try {
      List<MenuModel> menuItems = await repository.getMenuItems();
      emit(MenuApiLoaded(menuItems));
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onFetchMenuFromApi(
      FetchMenuFromApi event, Emitter<MenuApiState> emit) async {
    emit(MenuApiLoading());
    try {
      final success = await repository.fetchAndUpdateMenuFromApi();
      if (success) {
        List<MenuModel> menuItems = await repository.getMenuItems();
        emit(MenuApiLoaded(menuItems));
      } else {
        emit(MenuApiError("Failed to fetch menu from API"));
      }
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onAddMenuApiItem(
      AddMenuApiItem event, Emitter<MenuApiState> emit) async {
    final currentState = state;

    try {
      // Validate menu item
      if (event.menuItem.menuId.isEmpty ||
          event.menuItem.menuName.isEmpty ||
          event.menuItem.price.isEmpty) {
        emit(MenuApiError("Invalid menu item data"));
        return;
      }

      // Try to parse price
      if (double.tryParse(event.menuItem.price) == null) {
        emit(MenuApiError("Invalid price format"));
        return;
      }

      // Emit loading state
      emit(MenuApiLoading());

      // Actual repository operation
      final success = await repository.addMenuItem(event.menuItem);

      if (!success) {
        emit(MenuApiError("Failed to add menu item"));
        return;
      }

      // Fetch updated menu items
      final updatedMenu = await repository.getMenuItems();
      emit(MenuApiLoaded(updatedMenu));
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onRemoveMenuApiItem(
      RemoveMenuApiItem event, Emitter<MenuApiState> emit) async {
    final currentState = state;

    try {
      // Optimistic update
      if (currentState is MenuApiLoaded) {
        final updatedItems = List<MenuModel>.from(currentState.menuItems)
          ..removeWhere((item) => item.menuId == event.menuId);
        emit(MenuApiLoaded(updatedItems));
      }

      // Actual repository operation
      final success = await repository.deleteMenuItem(event.menuId);

      if (!success) {
        // If operation failed, revert
        emit(currentState);
        emit(MenuApiError("Failed to delete menu item"));
        return;
      }

      // If we weren't in loaded state before, fetch all data
      if (currentState is! MenuApiLoaded) {
        final updatedMenu = await repository.getMenuItems();
        emit(MenuApiLoaded(updatedMenu));
      }
    } catch (e) {
      emit(currentState); // Revert to previous state
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onUpdateMenuApiItem(
      UpdateMenuApiItem event, Emitter<MenuApiState> emit) async {
    final currentState = state;

    try {
      // Optimistic update
      if (currentState is MenuApiLoaded) {
        final updatedItems = List<MenuModel>.from(currentState.menuItems);
        final index = updatedItems
            .indexWhere((item) => item.menuId == event.menuItem.menuId);

        if (index != -1) {
          updatedItems[index] = event.menuItem;
          emit(MenuApiLoaded(updatedItems));
        }
      }

      // Actual repository operation
      final success = await repository.updateMenuItem(event.menuItem);

      if (!success) {
        // If operation failed, revert
        emit(currentState);
        emit(MenuApiError("Failed to update menu item"));
        return;
      }

      // If we weren't in loaded state before, fetch all data
      if (currentState is! MenuApiLoaded) {
        final updatedMenu = await repository.getMenuItems();
        emit(MenuApiLoaded(updatedMenu));
      }
    } catch (e) {
      emit(currentState); // Revert to previous state
      emit(MenuApiError(e.toString()));
    }
  }
}
