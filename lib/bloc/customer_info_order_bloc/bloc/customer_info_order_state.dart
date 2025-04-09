part of 'customer_info_order_bloc.dart';

abstract class CustomerInfoOrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class CustomerInfoOrderInitial extends CustomerInfoOrderState {}

class CustomerInfoOrderLoaded extends CustomerInfoOrderState {
  final CustomerInfoOrderModel customerInfo;

  CustomerInfoOrderLoaded(this.customerInfo);

  @override
  List<Object> get props => [customerInfo];
}
