part of 'cetagory_bloc.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final CategoryModel category;

  AddCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  UpdateCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  DeleteCategory({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}
