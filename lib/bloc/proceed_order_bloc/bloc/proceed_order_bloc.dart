import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/proceed_order_database.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';

part 'proceed_order_event.dart';
part 'proceed_order_state.dart';

class ProceedOrderBloc extends Bloc<ProceedOrderEvent, ProceedOrderState> {
  final ProceedOrderDatabaseHelper databaseHelper =
      ProceedOrderDatabaseHelper.instance;

  ProceedOrderBloc() : super(ProceedOrderInitial()) {
    on<LoadProceedOrders>((event, emit) async {
      emit(ProceedOrderLoading());
      try {
        final proceedOrders = await databaseHelper.fetchProceedOrders();
        emit(ProceedOrderLoaded(proceedOrders));
      } catch (e) {
        emit(const ProceedOrderError("Failed to load proceed orders"));
      }
    });

    on<AddProceedOrder>((event, emit) async {
      try {
        await databaseHelper.insertProceedOrder(event.proceedOrder);
        add(LoadProceedOrders()); // Refresh list
      } catch (e) {
        emit(const ProceedOrderError("Failed to add proceed order"));
      }
    });

    on<UpdateProceedOrder>((event, emit) async {
      try {
        await databaseHelper.updateProceedOrder(event.proceedOrder);
        add(LoadProceedOrders());
      } catch (e) {
        emit(const ProceedOrderError("Failed to update proceed order"));
      }
    });

    on<DeleteProceedOrder>((event, emit) async {
      try {
        await databaseHelper.deleteProceedOrder(event.holdOrderId);
        add(LoadProceedOrders());
      } catch (e) {
        emit(const ProceedOrderError("Failed to delete proceed order"));
      }
    });
  }
}
