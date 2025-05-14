part of 'ip_address_bloc.dart';

abstract class IpAddressEvent extends Equatable {
  const IpAddressEvent();

  @override
  List<Object> get props => [];
}

class LoadIpAddress extends IpAddressEvent {
  const LoadIpAddress();
}

class SaveIpAddress extends IpAddressEvent {
  final String ipAddress;

  const SaveIpAddress(this.ipAddress);

  @override
  List<Object> get props => [ipAddress];
}
