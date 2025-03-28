part of 'customer_info_bloc.dart';

abstract class CustomerInfoState extends Equatable {
  const CustomerInfoState();
  @override
  List<Object?> get props => [];
}

class CustomerInfoInitial extends CustomerInfoState {}

class CustomerInfoLoading extends CustomerInfoState {}

class CustomerInfoLoaded extends CustomerInfoState {
  final List<CustomerInfoModel> orders;
  const CustomerInfoLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}

class CustomerInfoByIdLoaded extends CustomerInfoState {
  final CustomerInfoModel order;
  const CustomerInfoByIdLoaded(this.order);
  @override
  List<Object> get props => [order];
}

class CustomerInfoError extends CustomerInfoState {
  final String message;
  const CustomerInfoError(this.message);
  @override
  List<Object> get props => [message];
}
