part of 'tax_settings_bloc.dart';

abstract class TaxSettingsEvent extends Equatable {
  const TaxSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaxSettings extends TaxSettingsEvent {}

class UpdateTaxSettings extends TaxSettingsEvent {
  final double bst;
  final double serviceCharge;

  const UpdateTaxSettings({
    required this.bst,
    required this.serviceCharge,
  });

  @override
  List<Object?> get props => [bst, serviceCharge];
}
