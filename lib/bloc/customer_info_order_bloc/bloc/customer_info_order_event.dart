part of 'customer_info_order_bloc.dart';

abstract class CustomerInfoOrderEvent extends Equatable {
  const CustomerInfoOrderEvent();

  @override
  List<Object?> get props => [];
}

class AddCustomerInfoOrder extends CustomerInfoOrderEvent {
  final String name;
  final String contact;
  final String orderId;
  final String tableNo;
  final String orderNumber;

  const AddCustomerInfoOrder({
    required this.name,
    required this.contact,
    required this.orderId,
    required this.tableNo,
    required this.orderNumber,
  });

  @override
  List<Object?> get props => [name, contact, orderId, tableNo, orderNumber];
}

class RemoveCustomerInfoOrder extends CustomerInfoOrderEvent {}
