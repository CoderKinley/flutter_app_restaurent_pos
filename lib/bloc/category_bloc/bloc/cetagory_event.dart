part of 'cetagory_bloc.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final CategoryModel category;

  AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class CheckCategoryUsage extends CategoryEvent {
  final String categoryId;

  CheckCategoryUsage(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
