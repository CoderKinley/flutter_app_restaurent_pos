import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'ip_address_event.dart';
part 'ip_address_state.dart';

class IpAddressBloc extends Bloc<IpAddressEvent, IpAddressState> {
  final SharedPreferences prefs;
  static const String ipAddressKey = 'server_ip_address';

  IpAddressBloc(this.prefs) : super(IpAddressInitial()) {
    on<LoadIpAddress>(_onLoadIpAddress);
    on<SaveIpAddress>(_onSaveIpAddress);
  }

  Future<void> _onLoadIpAddress(
      LoadIpAddress event, Emitter<IpAddressState> emit) async {
    emit(IpAddressLoading());
    try {
      final ipAddress = prefs.getString(ipAddressKey);
      if (ipAddress != null) {
        emit(IpAddressLoaded(ipAddress));
      } else {
        emit(IpAddressInitial());
      }
    } catch (e) {
      emit(IpAddressError('Failed to load IP address'));
    }
  }

  Future<void> _onSaveIpAddress(
      SaveIpAddress event, Emitter<IpAddressState> emit) async {
    emit(IpAddressLoading());
    try {
      await prefs.setString(ipAddressKey, event.ipAddress);
      emit(IpAddressLoaded(event.ipAddress));
    } catch (e) {
      emit(IpAddressError('Failed to save IP address'));
    }
  }
}
