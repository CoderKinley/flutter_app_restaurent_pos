part of 'customer_info_bloc.dart';

abstract class CustomerInfoEvent extends Equatable {
  const CustomerInfoEvent();
  @override
  List<Object?> get props => [];
}

class FetchCustomerOrders extends CustomerInfoEvent {}

class FetchCustomerOrderById extends CustomerInfoEvent {
  final String orderId;
  const FetchCustomerOrderById(this.orderId);
  @override
  List<Object> get props => [orderId];
}

class AddCustomerOrder extends CustomerInfoEvent {
  final CustomerInfoModel order;
  const AddCustomerOrder(this.order);
  @override
  List<Object> get props => [order];
}

class UpdateCustomerOrder extends CustomerInfoEvent {
  final CustomerInfoModel order;
  const UpdateCustomerOrder(this.order);
  @override
  List<Object> get props => [order];
}

class DeleteCustomerOrder extends CustomerInfoEvent {
  final String orderId;
  const DeleteCustomerOrder(this.orderId);
  @override
  List<Object> get props => [orderId];
}

class UpdateCustomerOrderById extends CustomerInfoEvent {
  final int orderId;
  final CustomerInfoModel updatedOrder;

  const UpdateCustomerOrderById(this.orderId, this.updatedOrder);

  @override
  List<Object> get props => [orderId, updatedOrder];
}
