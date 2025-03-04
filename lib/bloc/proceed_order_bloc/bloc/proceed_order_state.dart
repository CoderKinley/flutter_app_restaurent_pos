part of 'proceed_order_bloc.dart';

abstract class ProceedOrderState extends Equatable {
  const ProceedOrderState();

  @override
  List<Object> get props => [];
}

class ProceedOrderInitial extends ProceedOrderState {}

class ProceedOrderLoading extends ProceedOrderState {}

class ProceedOrderLoaded extends ProceedOrderState {
  final List<ProceedOrderModel> proceedOrders;

  const ProceedOrderLoaded(this.proceedOrders);

  @override
  List<Object> get props => [proceedOrders];
}

class ProceedOrderError extends ProceedOrderState {
  final String message;

  const ProceedOrderError(this.message);

  @override
  List<Object> get props => [message];
}
