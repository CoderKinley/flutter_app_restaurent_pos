part of 'proceed_order_bloc.dart';

abstract class ProceedOrderEvent extends Equatable {
  const ProceedOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadProceedOrders extends ProceedOrderEvent {}

class AddProceedOrder extends ProceedOrderEvent {
  final ProceedOrderModel proceedOrder;

  const AddProceedOrder(this.proceedOrder);

  @override
  List<Object> get props => [proceedOrder];
}

class UpdateProceedOrder extends ProceedOrderEvent {
  final ProceedOrderModel proceedOrder;

  const UpdateProceedOrder(this.proceedOrder);

  @override
  List<Object> get props => [proceedOrder];
}

class DeleteProceedOrder extends ProceedOrderEvent {
  final String holdOrderId;

  const DeleteProceedOrder(this.holdOrderId);

  @override
  List<Object> get props => [holdOrderId];
}
