part of 'navigation_bloc.dart';

// Define Events
abstract class NavigationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NavigateToSales extends NavigationEvent {}

class NavigateToReceipt extends NavigationEvent {}

class NavigateToItems extends NavigationEvent {}

class NavigateToNotification extends NavigationEvent {}

class NavigateToShift extends NavigationEvent {}

class NavigateToSettings extends NavigationEvent {}
