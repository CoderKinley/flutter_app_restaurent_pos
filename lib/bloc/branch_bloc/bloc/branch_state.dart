part of 'branch_bloc.dart';

abstract class BranchState extends Equatable {
  const BranchState();

  @override
  List<Object> get props => [];
}

class BranchInitial extends BranchState {}

class BranchLoading extends BranchState {}

class BranchLoaded extends BranchState {
  final String branchName;
  final String branchCode;

  const BranchLoaded({
    required this.branchName,
    required this.branchCode,
  });

  @override
  List<Object> get props => [branchName, branchCode];
}

class BranchError extends BranchState {
  final String message;

  const BranchError(this.message);

  @override
  List<Object> get props => [message];
}
