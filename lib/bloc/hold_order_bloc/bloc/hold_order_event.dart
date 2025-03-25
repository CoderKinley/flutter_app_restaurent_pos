part of 'hold_order_bloc.dart';

abstract class HoldOrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHoldOrders extends HoldOrderEvent {}

class AddHoldOrder extends HoldOrderEvent {
  final HoldOrderModel holdOrder;
  AddHoldOrder(this.holdOrder);

  @override
  List<Object?> get props => [holdOrder];
}

class UpdateHoldOrder extends HoldOrderEvent {
  final HoldOrderModel holdOrder;
  UpdateHoldOrder(this.holdOrder);

  @override
  List<Object?> get props => [holdOrder];
}

class LoadHoldOrdersById extends HoldOrderEvent {
  final String holdOrderId;
  LoadHoldOrdersById(this.holdOrderId);

  @override
  List<Object?> get props => [holdOrderId];
}

class DeleteHoldOrder extends HoldOrderEvent {
  final String holdOrderId;
  DeleteHoldOrder(this.holdOrderId);

  @override
  List<Object?> get props => [holdOrderId];
}


// Id, Name, Contactnumber and table number should be same but above all the ID should be same for the same quantity
