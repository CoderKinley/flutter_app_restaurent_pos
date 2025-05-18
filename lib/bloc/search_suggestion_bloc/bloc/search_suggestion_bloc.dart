import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/models/search/search_suggestion_model.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Events
abstract class SearchSuggestionEvent extends Equatable {
  const SearchSuggestionEvent();

  @override
  List<Object> get props => [];
}

class UpdateSearchSuggestions extends SearchSuggestionEvent {
  final String query;
  final List<MenuModel> menuItems;

  const UpdateSearchSuggestions({
    required this.query,
    required this.menuItems,
  });

  @override
  List<Object> get props => [query, menuItems];
}

// States
abstract class SearchSuggestionState extends Equatable {
  const SearchSuggestionState();

  @override
  List<Object> get props => [];
}

class SearchSuggestionInitial extends SearchSuggestionState {}

class SearchSuggestionLoading extends SearchSuggestionState {}

class SearchSuggestionLoaded extends SearchSuggestionState {
  final List<SearchSuggestionModel> suggestions;

  const SearchSuggestionLoaded(this.suggestions);

  @override
  List<Object> get props => [suggestions];
}

class SearchSuggestionError extends SearchSuggestionState {
  final String message;

  const SearchSuggestionError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  SearchSuggestionBloc() : super(SearchSuggestionInitial()) {
    on<UpdateSearchSuggestions>(_onUpdateSearchSuggestions);
  }

  void _onUpdateSearchSuggestions(
    UpdateSearchSuggestions event,
    Emitter<SearchSuggestionState> emit,
  ) {
    try {
      emit(SearchSuggestionLoading());

      if (event.query.isEmpty) {
        emit(const SearchSuggestionLoaded([]));
        return;
      }

      final suggestions = event.menuItems
          .where((item) =>
              item.menuName.toLowerCase().contains(event.query.toLowerCase()))
          .map((item) => SearchSuggestionModel(
                menuId: item.menuId,
                menuName: item.menuName,
              ))
          .toList();

      emit(SearchSuggestionLoaded(suggestions));
    } catch (e) {
      emit(SearchSuggestionError(e.toString()));
    }
  }
}
