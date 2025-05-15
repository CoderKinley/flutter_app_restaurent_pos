part of 'branch_bloc.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object> get props => [];
}

class LoadBranch extends BranchEvent {
  const LoadBranch();
}

class SaveBranch extends BranchEvent {
  final String branchName;
  final String branchCode;

  const SaveBranch({
    required this.branchName,
    required this.branchCode,
  });

  @override
  List<Object> get props => [branchName, branchCode];
}
