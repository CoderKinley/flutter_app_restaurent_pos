part of 'add_item_navigation_bloc.dart';

abstract class AddItemNavigationEvent extends Equatable {
  const AddItemNavigationEvent();

  @override
  List<Object> get props => [];
}

class SelectScreen extends AddItemNavigationEvent {
  final int index;
  const SelectScreen(this.index);

  @override
  List<Object> get props => [index];
}
