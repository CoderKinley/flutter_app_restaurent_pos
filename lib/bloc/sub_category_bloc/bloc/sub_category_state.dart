part of 'sub_category_bloc.dart';

abstract class SubcategoryState extends Equatable {
  const SubcategoryState();

  @override
  List<Object> get props => [];
}

class SubcategoryInitial extends SubcategoryState {}

class SubcategoryLoading extends SubcategoryState {}

class SubcategoryLoaded extends SubcategoryState {
  final List<SubcategoryModel> subcategories;

  const SubcategoryLoaded({required this.subcategories});

  @override
  List<Object> get props => [subcategories];
}

class SubcategoryError extends SubcategoryState {
  final String errorMessage;

  const SubcategoryError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
