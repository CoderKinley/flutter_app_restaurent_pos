part of 'navigation_bloc.dart';

// Define States
abstract class NavigationState extends Equatable {
  final Widget page;
  const NavigationState(this.page);

  @override
  List<Object?> get props => [page];
}

class SalesPageState extends NavigationState {
  final HoldOrderModel? holdOrderModel;

  // Constructor to pass the holdOrderModel
  SalesPageState({this.holdOrderModel})
      : super(SalesPage(hold_order_model: holdOrderModel));

  @override
  List<Object?> get props => [holdOrderModel];
}

class ReceiptPageState extends NavigationState {
  const ReceiptPageState() : super(const ReceiptPage());
}

class ItemsPageState extends NavigationState {
  ItemsPageState() : super(ItemsPage());
}

class NotificationPageState extends NavigationState {
  const NotificationPageState() : super(const NotificationPage());
}

class ShiftPageState extends NavigationState {
  const ShiftPageState() : super(const ShiftPage());
}

class SettingsPageState extends NavigationState {
  const SettingsPageState() : super(const SettingPage());
}
