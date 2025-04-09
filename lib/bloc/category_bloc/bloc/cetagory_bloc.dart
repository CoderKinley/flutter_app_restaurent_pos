import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/category_databasehelper.dart';
import 'package:pos_system_legphel/SQL/database_helper.dart';
import 'package:pos_system_legphel/models/others/category_model.dart';

part 'cetagory_event.dart';
part 'cetagory_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryDatabaseHelper _categoryDatabase =
      CategoryDatabaseHelper.instance;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<CheckCategoryUsage>(_onCheckCategoryUsage);
  }

  // Load Categories from Database
  void _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryDatabase.fetchCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(errorMessage: "Failed to load categories: $e"));
    }
  }

  // Add a new Category
  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryDatabase.insertCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(errorMessage: "Failed to add category: $e"));
    }
  }

  void _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryDatabase.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(errorMessage: "Failed to update category: $e"));
    }
  }

  void _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryDatabase.deleteCategory(event.categoryId);
      add(LoadCategories()); // Reload categories after deletion
    } catch (e) {
      emit(CategoryError(errorMessage: "Failed to delete category: $e"));
    }
  }

  void _onCheckCategoryUsage(
      CheckCategoryUsage event, Emitter<CategoryState> emit) async {
    try {
      final isUsed = await databaseHelper.isCategoryUsed(event.categoryId);
      print(isUsed);
      emit(CategoryUsageChecked(isUsed));
    } catch (e) {
      emit(CategoryError(errorMessage: "Failed to check category usage: $e"));
    }
  }
}
