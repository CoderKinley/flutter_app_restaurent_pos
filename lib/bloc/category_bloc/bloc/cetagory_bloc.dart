import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/category_databasehelper.dart';
import 'package:pos_system_legphel/models/category_model.dart';

part 'cetagory_event.dart';
part 'cetagory_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryDatabaseHelper _categoryDatabase =
      CategoryDatabaseHelper.instance;

  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
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
}
