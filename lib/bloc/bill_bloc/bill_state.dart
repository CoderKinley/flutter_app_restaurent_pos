part of 'bill_bloc.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  final BillSummaryModel billSummary;
  final List<BillDetailsModel> billDetails;

  const BillLoaded({
    required this.billSummary,
    required this.billDetails,
  });

  @override
  List<Object?> get props => [billSummary, billDetails];
}

class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object?> get props => [message];
}

class BillSubmitted extends BillState {
  final String fnbBillNo;

  const BillSubmitted(this.fnbBillNo);

  @override
  List<Object?> get props => [fnbBillNo];
}
