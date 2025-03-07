import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/views/pages/items_page.dart';
import 'package:pos_system_legphel/views/pages/notification_page.dart';
import 'package:pos_system_legphel/views/pages/receipt_page.dart';
import 'package:pos_system_legphel/views/pages/sales_page.dart';
import 'package:pos_system_legphel/views/pages/setting_page.dart';
import 'package:pos_system_legphel/views/pages/shift_page.dart';

part 'navigation_state.dart';
part 'navigation_events.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const SalesPageState()) {
    on<NavigateToSales>((event, emit) {
      emit(const SalesPageState());
    });
    on<NavigateToReceipt>((event, emit) => emit(const ReceiptPageState()));
    on<NavigateToItems>((event, emit) => emit(ItemsPageState()));
    on<NavigateToNotification>(
        (event, emit) => emit(const NotificationPageState()));
    on<NavigateToShift>((event, emit) => emit(const ShiftPageState()));
    on<NavigateToSettings>((event, emit) => emit(const SettingsPageState()));
  }
}
