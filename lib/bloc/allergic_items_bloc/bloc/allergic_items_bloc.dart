import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/SQL/allergic_items_database.dart';
import 'package:pos_system_legphel/models/Menu Model/allergic_item_model.dart';

// Events
abstract class AllergicItemsEvent {}

class LoadAllergicItems extends AllergicItemsEvent {}

class AddAllergicItem extends AllergicItemsEvent {
  final AllergicItemModel item;
  AddAllergicItem(this.item);
}

class UpdateAllergicItem extends AllergicItemsEvent {
  final AllergicItemModel item;
  UpdateAllergicItem(this.item);
}

class DeleteAllergicItem extends AllergicItemsEvent {
  final String id;
  DeleteAllergicItem(this.id);
}

// States
abstract class AllergicItemsState {}

class AllergicItemsInitial extends AllergicItemsState {}

class AllergicItemsLoading extends AllergicItemsState {}

class AllergicItemsLoaded extends AllergicItemsState {
  final List<AllergicItemModel> items;
  AllergicItemsLoaded(this.items);
}

class AllergicItemsError extends AllergicItemsState {
  final String message;
  AllergicItemsError(this.message);
}

// BLoC
class AllergicItemsBloc extends Bloc<AllergicItemsEvent, AllergicItemsState> {
  final AllergicItemsDatabase _database = AllergicItemsDatabase.instance;

  AllergicItemsBloc() : super(AllergicItemsInitial()) {
    on<LoadAllergicItems>(_onLoadAllergicItems);
    on<AddAllergicItem>(_onAddAllergicItem);
    on<UpdateAllergicItem>(_onUpdateAllergicItem);
    on<DeleteAllergicItem>(_onDeleteAllergicItem);
  }

  Future<void> _onLoadAllergicItems(
    LoadAllergicItems event,
    Emitter<AllergicItemsState> emit,
  ) async {
    try {
      emit(AllergicItemsLoading());
      final items = await _database.getAllItems();
      emit(AllergicItemsLoaded(items));
    } catch (e) {
      emit(AllergicItemsError(e.toString()));
    }
  }

  Future<void> _onAddAllergicItem(
    AddAllergicItem event,
    Emitter<AllergicItemsState> emit,
  ) async {
    try {
      await _database.insert(event.item);
      final items = await _database.getAllItems();
      emit(AllergicItemsLoaded(items));
    } catch (e) {
      emit(AllergicItemsError(e.toString()));
    }
  }

  Future<void> _onUpdateAllergicItem(
    UpdateAllergicItem event,
    Emitter<AllergicItemsState> emit,
  ) async {
    try {
      await _database.update(event.item);
      final items = await _database.getAllItems();
      emit(AllergicItemsLoaded(items));
    } catch (e) {
      emit(AllergicItemsError(e.toString()));
    }
  }

  Future<void> _onDeleteAllergicItem(
    DeleteAllergicItem event,
    Emitter<AllergicItemsState> emit,
  ) async {
    try {
      await _database.delete(event.id);
      final items = await _database.getAllItems();
      emit(AllergicItemsLoaded(items));
    } catch (e) {
      emit(AllergicItemsError(e.toString()));
    }
  }
}
