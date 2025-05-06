import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_item_navigation_event.dart';
part 'add_item_navigation_state.dart';

class AddItemNavigationBloc
    extends Bloc<AddItemNavigationEvent, AddItemNavigationState> {
  AddItemNavigationBloc() : super(const AddItemNavigationState(0)) {
    on<SelectScreen>((event, emit) {
      emit(
        AddItemNavigationState(event.index),
      );
    });
  }
}
