part of 'hold_order_bloc.dart';

abstract class HoldOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HoldOrderInitial extends HoldOrderState {}

class HoldOrderLoading extends HoldOrderState {}

class HoldOrderLoaded extends HoldOrderState {
  final List<HoldOrderModel> holdOrders;
  HoldOrderLoaded(this.holdOrders);

  @override
  List<Object?> get props => [holdOrders];
}

class HoldOrderError extends HoldOrderState {
  final String message;
  HoldOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
