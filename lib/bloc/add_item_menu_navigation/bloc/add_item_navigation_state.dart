part of 'add_item_navigation_bloc.dart';

class AddItemNavigationState extends Equatable {
  final int selectedIndex;
  const AddItemNavigationState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
