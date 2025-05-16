part of 'tax_settings_bloc.dart';

abstract class TaxSettingsState extends Equatable {
  const TaxSettingsState();

  @override
  List<Object?> get props => [];
}

class TaxSettingsInitial extends TaxSettingsState {}

class TaxSettingsLoading extends TaxSettingsState {}

class TaxSettingsLoaded extends TaxSettingsState {
  final double bst;
  final double serviceCharge;

  const TaxSettingsLoaded({
    required this.bst,
    required this.serviceCharge,
  });

  @override
  List<Object?> get props => [bst, serviceCharge];
}

class TaxSettingsError extends TaxSettingsState {
  final String message;

  const TaxSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
