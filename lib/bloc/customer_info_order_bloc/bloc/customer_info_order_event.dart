part of 'customer_info_order_bloc.dart';

abstract class CustomerInfoOrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddCustomerInfoOrder extends CustomerInfoOrderEvent {
  final String name;
  final String contact;
  final String orderId;
  final String tableNo;

  AddCustomerInfoOrder({
    required this.name,
    required this.contact,
    required this.orderId,
    required this.tableNo,
  });

  @override
  List<Object> get props => [name, contact, orderId, tableNo];
}

class RemoveCustomerInfoOrder extends CustomerInfoOrderEvent {
  RemoveCustomerInfoOrder();

  @override
  List<Object> get props => [];
}
