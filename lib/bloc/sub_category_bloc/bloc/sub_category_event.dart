part of 'sub_category_bloc.dart';

abstract class SubcategoryEvent extends Equatable {
  const SubcategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSubcategories extends SubcategoryEvent {
  final String categoryId;

  const LoadSubcategories({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class AddSubcategory extends SubcategoryEvent {
  final SubcategoryModel subcategorylist;

  const AddSubcategory({
    required this.subcategorylist,
  });

  @override
  List<Object> get props => [subcategorylist];
}

class UpdateSubcategory extends SubcategoryEvent {
  final SubcategoryModel subcategory;

  const UpdateSubcategory({required this.subcategory});

  @override
  List<Object> get props => [subcategory];
}

class DeleteSubcategory extends SubcategoryEvent {
  final String subcategoryId;
  final String categoryId;

  const DeleteSubcategory(
      {required this.subcategoryId, required this.categoryId});

  @override
  List<Object> get props => [subcategoryId, categoryId];
}

class LoadAllSubcategory extends SubcategoryEvent {
  @override
  List<Object> get props => [];
}
