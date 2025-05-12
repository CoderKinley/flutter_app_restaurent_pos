part of 'customer_info_order_bloc.dart';

abstract class CustomerInfoOrderState extends Equatable {
  const CustomerInfoOrderState();

  @override
  List<Object?> get props => [];
}

class CustomerInfoOrderInitial extends CustomerInfoOrderState {}

class CustomerInfoOrderLoaded extends CustomerInfoOrderState {
  final CustomerInfoOrderModel customerInfo;

  const CustomerInfoOrderLoaded(this.customerInfo);

  @override
  List<Object?> get props => [customerInfo];
}

class CustomerInfoOrderRemoved extends CustomerInfoOrderState {}
