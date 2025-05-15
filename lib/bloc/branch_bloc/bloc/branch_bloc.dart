import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'branch_event.dart';
part 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final SharedPreferences prefs;
  static const String branchNameKey = 'hotel_branch_name';
  static const String branchCodeKey = 'hotel_branch_code';

  BranchBloc(this.prefs) : super(BranchInitial()) {
    on<LoadBranch>(_onLoadBranch);
    on<SaveBranch>(_onSaveBranch);
  }

  Future<void> _onLoadBranch(
      LoadBranch event, Emitter<BranchState> emit) async {
    emit(BranchLoading());
    try {
      final branchName = prefs.getString(branchNameKey);
      final branchCode = prefs.getString(branchCodeKey);
      if (branchName != null && branchCode != null) {
        emit(BranchLoaded(branchName: branchName, branchCode: branchCode));
      } else {
        emit(BranchInitial());
      }
    } catch (e) {
      emit(BranchError('Failed to load branch information'));
    }
  }

  Future<void> _onSaveBranch(
      SaveBranch event, Emitter<BranchState> emit) async {
    emit(BranchLoading());
    try {
      await prefs.setString(branchNameKey, event.branchName);
      await prefs.setString(branchCodeKey, event.branchCode);
      emit(BranchLoaded(
          branchName: event.branchName, branchCode: event.branchCode));
    } catch (e) {
      emit(BranchError('Failed to save branch information'));
    }
  }
}
