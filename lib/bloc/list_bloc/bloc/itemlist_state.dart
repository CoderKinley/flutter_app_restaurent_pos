part of 'itemlist_bloc.dart';

class ItemlistState extends Equatable {
  const ItemlistState({
    this.itemList = const [],
  });

  final List<String> itemList;

  ItemlistState copyWith({itemList}) {
    return ItemlistState(
      itemList: itemList ?? this.itemList,
    );
  }

  @override
  List<Object> get props => [];
}
