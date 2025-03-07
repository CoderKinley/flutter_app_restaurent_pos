part of 'cetagory_bloc.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  CategoryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String errorMessage;

  CategoryError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class CategoryUsageChecked extends CategoryState {
  final bool isUsed;

  CategoryUsageChecked(this.isUsed);

  @override
  List<Object?> get props => [isUsed];
}
