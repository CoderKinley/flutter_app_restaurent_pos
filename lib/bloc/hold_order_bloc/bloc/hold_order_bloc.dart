import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos_system_legphel/SQL/hold_order_databasehelper.dart';
import 'package:pos_system_legphel/models/Menu%20Model/hold_order_model.dart';

part 'hold_order_event.dart';
part 'hold_order_state.dart';

class HoldOrderBloc extends Bloc<HoldOrderEvent, HoldOrderState> {
  final HoldOrderDatabaseHelper databaseHelper =
      HoldOrderDatabaseHelper.instance;

  HoldOrderBloc() : super(HoldOrderInitial()) {
    on<LoadHoldOrders>((event, emit) async {
      emit(HoldOrderLoading());
      try {
        final holdOrders = await databaseHelper.fetchHoldOrders();
        emit(HoldOrderLoaded(holdOrders));
      } catch (e) {
        emit(HoldOrderError("Failed to load hold orders"));
      }
    });

    on<AddHoldOrder>((event, emit) async {
      try {
        await databaseHelper.insertHoldOrder(event.holdOrder);
        add(LoadHoldOrders()); // Refresh list
      } catch (e) {
        emit(HoldOrderError("Failed to add hold order"));
      }
    });

    on<UpdateHoldOrder>((event, emit) async {
      try {
        await databaseHelper.updateHoldOrder(event.holdOrder);
        add(LoadHoldOrders());
      } catch (e) {
        emit(HoldOrderError("Failed to update hold order"));
      }
    });

    on<DeleteHoldOrder>((event, emit) async {
      try {
        await databaseHelper.deleteHoldOrder(event.holdOrderId);
        add(LoadHoldOrders());
      } catch (e) {
        emit(HoldOrderError("Failed to delete hold order"));
      }
    });

    on<LoadHoldOrdersById>((event, emit) async {
      try {
        await databaseHelper.fetchHoldOrderById(event.holdOrderId);
        add(LoadHoldOrders());
      } catch (e) {
        emit(HoldOrderError("failed to Load by Id"));
      }
    });
  }
}
