part of 'ip_address_bloc.dart';

abstract class IpAddressState extends Equatable {
  const IpAddressState();

  @override
  List<Object> get props => [];
}

class IpAddressInitial extends IpAddressState {}

class IpAddressLoading extends IpAddressState {}

class IpAddressLoaded extends IpAddressState {
  final String ipAddress;

  const IpAddressLoaded(this.ipAddress);

  @override
  List<Object> get props => [ipAddress];
}

class IpAddressError extends IpAddressState {
  final String message;

  const IpAddressError(this.message);

  @override
  List<Object> get props => [message];
}
