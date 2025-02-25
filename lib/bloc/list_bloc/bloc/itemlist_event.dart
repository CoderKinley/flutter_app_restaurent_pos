part of 'itemlist_bloc.dart';

// act as a base class
abstract class ItemlistEvent extends Equatable {
  const ItemlistEvent();
}

class AddItemEvent extends ItemlistEvent {
  final String task;

  const AddItemEvent({required this.task});

  @override
  List<Object> get props => [task];
}

class RemoveItemEvent extends ItemlistEvent {
  @override
  List<Object> get props => [];
}
