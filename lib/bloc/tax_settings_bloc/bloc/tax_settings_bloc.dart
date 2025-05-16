import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'tax_settings_event.dart';
part 'tax_settings_state.dart';

class TaxSettingsBloc extends Bloc<TaxSettingsEvent, TaxSettingsState> {
  final SharedPreferences prefs;
  static const String bstKey = 'tax_settings_bst';
  static const String serviceChargeKey = 'tax_settings_service_charge';

  TaxSettingsBloc(this.prefs) : super(TaxSettingsInitial()) {
    on<LoadTaxSettings>(_onLoadTaxSettings);
    on<UpdateTaxSettings>(_onUpdateTaxSettings);
  }

  Future<void> _onLoadTaxSettings(
      LoadTaxSettings event, Emitter<TaxSettingsState> emit) async {
    emit(TaxSettingsLoading());
    try {
      final bst = prefs.getDouble(bstKey) ?? 0.0;
      final serviceCharge = prefs.getDouble(serviceChargeKey) ?? 0.0;
      emit(TaxSettingsLoaded(bst: bst, serviceCharge: serviceCharge));
    } catch (e) {
      emit(TaxSettingsError('Failed to load tax settings'));
    }
  }

  Future<void> _onUpdateTaxSettings(
      UpdateTaxSettings event, Emitter<TaxSettingsState> emit) async {
    emit(TaxSettingsLoading());
    try {
      await prefs.setDouble(bstKey, event.bst);
      await prefs.setDouble(serviceChargeKey, event.serviceCharge);
      emit(TaxSettingsLoaded(
          bst: event.bst, serviceCharge: event.serviceCharge));
    } catch (e) {
      emit(TaxSettingsError('Failed to save tax settings'));
    }
  }
}
