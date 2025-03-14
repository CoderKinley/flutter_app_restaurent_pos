import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/menu_local_db.dart';
import 'package:pos_system_legphel/data/repositories/menu_repository.dart';
import 'package:pos_system_legphel/models/new_menu_model.dart';

part 'menu_from_api_event.dart';
part 'menu_from_api_state.dart';

class MenuBlocApi extends Bloc<MenuApiEvent, MenuApiState> {
  final MenuRepository repository;
  final MenuLocalDb menuLocalDB = MenuLocalDb.instance;

  MenuBlocApi(this.repository) : super(MenuApiInitial()) {
    on<FetchMenuApi>(_onFetchMenuApi);
    on<AddMenuApiItem>(_onAddMenuApiItem);
    on<RemoveMenuApiItem>(_onRemoveMenuApiItem);
    on<UpdateMenuApiItem>(_onUpdateMenuApiItem);
  }
  Future<void> _onFetchMenuApi(
      FetchMenuApi event, Emitter<MenuApiState> emit) async {
    emit(MenuApiLoading());
    try {
      List<MenuModel> localMenuItems = await repository.getMenuItems();
      if (localMenuItems.isNotEmpty) {
        emit(MenuApiLoaded(localMenuItems));
      }

      // Sync with API
      // await repository.syncMenuItems();
      // List<MenuModel> menuItems = await repository.getMenuItems();
      emit(MenuApiLoaded(localMenuItems));
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onAddMenuApiItem(
      AddMenuApiItem event, Emitter<MenuApiState> emit) async {
    try {
      await repository.localDb.insertMenuItem(event.menuItem);
      List<MenuModel> updatedMenu = await repository.getMenuItems();
      emit(MenuApiLoaded(updatedMenu));
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onRemoveMenuApiItem(
      RemoveMenuApiItem event, Emitter<MenuApiState> emit) async {
    try {
      // bool isDeleted = await repository.deleteMenuItem(event.menuId);
      menuLocalDB.deleteMenuItem(event.menuId);
      List<MenuModel> updatedMenu = await repository.getMenuItems();
      emit(MenuApiLoaded(updatedMenu));
      // if (isDeleted) {
      //   emit(MenuApiLoaded(updatedMenu));
      // } else {
      //   emit(const MenuApiError("Failed to delete menu item from API"));
      // }
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }

  Future<void> _onUpdateMenuApiItem(
      UpdateMenuApiItem event, Emitter<MenuApiState> emit) async {
    try {
      final db = await repository.localDb.database;
      await db.update('menu', event.menuItem.toJson(),
          where: 'menu_id = ?', whereArgs: [event.menuItem.menuId]);

      List<MenuModel> updatedMenu = await repository.getMenuItems();
      emit(MenuApiLoaded(updatedMenu));
    } catch (e) {
      emit(MenuApiError(e.toString()));
    }
  }
}
