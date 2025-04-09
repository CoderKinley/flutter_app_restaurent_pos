import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/table_and_name.dart';
import 'package:pos_system_legphel/models/tables%20and%20names/customer_info_model.dart';

part 'customer_info_event.dart';
part 'customer_info_state.dart';

class CustomerInfoBloc extends Bloc<CustomerInfoEvent, CustomerInfoState> {
  final CustomerInfoDatabaseHelper dbHelper =
      CustomerInfoDatabaseHelper.instance;
  CustomerInfoBloc() : super(CustomerInfoInitial()) {
    on<FetchCustomerOrders>(_onFetchCustomerOrders);
    on<FetchCustomerOrderById>(_onFetchCustomerOrderById);
    on<AddCustomerOrder>(_onAddCustomerOrder);
    on<UpdateCustomerOrder>(_onUpdateCustomerOrder);
    on<DeleteCustomerOrder>(_onDeleteCustomerOrder);
    on<UpdateCustomerOrderById>(_onUpdateCustomerOrderById);
  }

  Future<void> _onFetchCustomerOrders(
      FetchCustomerOrders event, Emitter<CustomerInfoState> emit) async {
    emit(CustomerInfoLoading());
    try {
      final orders = await dbHelper.fetchCustomerOrders();
      emit(CustomerInfoLoaded(orders));
    } catch (e) {
      emit(CustomerInfoError(e.toString()));
    }
  }

  Future<void> _onFetchCustomerOrderById(
      FetchCustomerOrderById event, Emitter<CustomerInfoState> emit) async {
    emit(CustomerInfoLoading());
    try {
      final order = await dbHelper.fetchCustomerOrderById(event.orderId);
      if (order != null) {
        emit(CustomerInfoByIdLoaded(order));
      } else {
        emit(const CustomerInfoError("Order not found"));
      }
    } catch (e) {
      emit(CustomerInfoError(e.toString()));
    }
  }

  Future<void> _onAddCustomerOrder(
      AddCustomerOrder event, Emitter<CustomerInfoState> emit) async {
    try {
      await dbHelper.insertCustomerOrder(event.order);
      add(FetchCustomerOrders()); // Refresh list
    } catch (e) {
      emit(CustomerInfoError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomerOrder(
      UpdateCustomerOrder event, Emitter<CustomerInfoState> emit) async {
    try {
      await dbHelper.updateCustomerOrder(event.order);
      add(FetchCustomerOrders()); // Refresh list
    } catch (e) {
      emit(CustomerInfoError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomerOrder(
      DeleteCustomerOrder event, Emitter<CustomerInfoState> emit) async {
    try {
      await dbHelper.deleteCustomerOrder(event.orderId);
      add(FetchCustomerOrders()); // Refresh list
    } catch (e) {
      emit(CustomerInfoError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomerOrderById(
      UpdateCustomerOrderById event, Emitter<CustomerInfoState> emit) async {
    try {
      await dbHelper.updateCustomerOrderById(event.orderId, event.updatedOrder);
      add(FetchCustomerOrders()); // Refresh the list
    } catch (e) {
      emit(CustomerInfoError(e.toString()));
    }
  }
}
