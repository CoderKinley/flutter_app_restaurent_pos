import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'itemlist_event.dart';
part 'itemlist_state.dart';

class ItemlistBloc extends Bloc<ItemlistEvent, ItemlistState> {
  final List<String> newItemList = [];

  ItemlistBloc() : super(const ItemlistState()) {
    on<AddItemEvent>(_addItem);
  }

  void _addItem(AddItemEvent event, Emitter<ItemlistState> emit) {
    newItemList.add(event.task);
    emit(
      state.copyWith(
        itemList: List.from(newItemList),
      ),
    );
  }
}
