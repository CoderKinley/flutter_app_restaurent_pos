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

  // Event handler for adding customer info order
  void _onAddCustomerInfoOrder(
    AddCustomerInfoOrder event,
    Emitter<CustomerInfoOrderState> emit,
  ) {
    // Create a new CustomerInfoOrderModel instance with the values from the event
    final customerInfo = CustomerInfoOrderModel(
      name: event.name,
      contact: event.contact,
      orderId: event.orderId,
      tableNo: event.tableNo,
    );

    // Emit the loaded state with the new customer info
    emit(CustomerInfoOrderLoaded(customerInfo));
  }

  void _onRemoveCustomerInfoOrder(
      RemoveCustomerInfoOrder event, Emitter<CustomerInfoOrderState> emit) {
    final customerInfo = CustomerInfoOrderModel(
      contact: "",
      orderId: "",
      name: "",
      tableNo: "",
    );

    emit(CustomerInfoOrderLoaded(customerInfo));
  }
}
