import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/models/Customer%20Information/customer_info_order_model.dart';

part 'customer_info_order_event.dart';
part 'customer_info_order_state.dart';

class CustomerInfoOrderBloc
    extends Bloc<CustomerInfoOrderEvent, CustomerInfoOrderState> {
  CustomerInfoOrderBloc() : super(CustomerInfoOrderInitial()) {
    on<AddCustomerInfoOrder>(_onAddCustomerInfoOrder);
    on<RemoveCustomerInfoOrder>(_onRemoveCustomerInfoOrder);
  }

  void _onAddCustomerInfoOrder(
    AddCustomerInfoOrder event,
    Emitter<CustomerInfoOrderState> emit,
  ) {
    final customerInfo = CustomerInfoOrderModel(
      name: event.name,
      contact: event.contact,
      orderId: event.orderId,
      tableNo: event.tableNo,
      orderNumber: event.orderNumber,
    );

    emit(CustomerInfoOrderLoaded(customerInfo));
  }

  void _onRemoveCustomerInfoOrder(
    RemoveCustomerInfoOrder event,
    Emitter<CustomerInfoOrderState> emit,
  ) {
    emit(CustomerInfoOrderRemoved());
  }
}
