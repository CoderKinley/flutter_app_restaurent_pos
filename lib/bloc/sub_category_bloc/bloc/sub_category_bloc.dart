import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/category_databasehelper.dart';
import 'package:pos_system_legphel/models/others/sub_category_model.dart';

part 'sub_category_event.dart';
part 'sub_category_state.dart';

class SubcategoryBloc extends Bloc<SubcategoryEvent, SubcategoryState> {
  final CategoryDatabaseHelper _subcategoryDatabase =
      CategoryDatabaseHelper.instance;

  SubcategoryBloc() : super(SubcategoryInitial()) {
    on<LoadSubcategories>(_onLoadSubcategories);
    on<AddSubcategory>(_onAddSubcategory);
    on<UpdateSubcategory>(_onUpdateSubcategory);
    on<DeleteSubcategory>(_onDeleteSubcategory);
    on<LoadAllSubcategory>(_onLoadAllSubcategory);
  }
// Load all subcategories
  void _onLoadAllSubcategory(
      LoadAllSubcategory event, Emitter<SubcategoryState> emit) async {
    try {
      final subcategories = await _subcategoryDatabase.fetchAllSubcategories();
      emit(SubcategoryLoaded(subcategories: subcategories));
    } catch (e) {
      emit(SubcategoryError(
          errorMessage: "Failed to Load all subcategoories: $e"));
    }
  }

  // Load Subcategories from Database
  void _onLoadSubcategories(
      LoadSubcategories event, Emitter<SubcategoryState> emit) async {
    emit(SubcategoryLoading());
    try {
      final subcategories = await _subcategoryDatabase
          .fetchSubcategoriesByCategoryId(event.categoryId);
      emit(SubcategoryLoaded(subcategories: subcategories));
    } catch (e) {
      emit(SubcategoryError(errorMessage: "Failed to load subcategories: $e"));
    }
  }

  // Add a new Subcategory
  void _onAddSubcategory(
      AddSubcategory event, Emitter<SubcategoryState> emit) async {
    try {
      await _subcategoryDatabase.insertSubcategory(event.subcategorylist);
      add(LoadSubcategories(categoryId: event.subcategorylist.categoryId));
    } catch (e) {
      emit(SubcategoryError(errorMessage: "Failed to add subcategory: $e"));
    }
  }

  // Update an existing Subcategory
  void _onUpdateSubcategory(
      UpdateSubcategory event, Emitter<SubcategoryState> emit) async {
    try {
      await _subcategoryDatabase.updateSubcategory(event.subcategory);
      add(LoadSubcategories(categoryId: event.subcategory.categoryId));
    } catch (e) {
      emit(SubcategoryError(errorMessage: "Failed to update subcategory: $e"));
    }
  }

  // Delete a Subcategory
  void _onDeleteSubcategory(
      DeleteSubcategory event, Emitter<SubcategoryState> emit) async {
    try {
      await _subcategoryDatabase.deleteSubcategory(event.subcategoryId);
      add(LoadSubcategories(
          categoryId:
              event.subcategoryId)); // Reload subcategories after deletion
    } catch (e) {
      emit(SubcategoryError(errorMessage: "Failed to delete subcategory: $e"));
    }
  }
}
