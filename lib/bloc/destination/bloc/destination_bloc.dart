import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/models/destination_model.dart';
import 'package:pos_system_legphel/services/database_helper.dart';

// Events
abstract class DestinationEvent {}

class LoadDestinations extends DestinationEvent {}

class AddDestination extends DestinationEvent {
  final String name;

  AddDestination({required this.name});
}

class UpdateDestination extends DestinationEvent {
  final Destination destination;

  UpdateDestination({required this.destination});
}

class DeleteDestination extends DestinationEvent {
  final int id;

  DeleteDestination({required this.id});
}

// States
abstract class DestinationState {}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationLoaded extends DestinationState {
  final List<Destination> destinations;

  DestinationLoaded(this.destinations);
}

class DestinationError extends DestinationState {
  final String message;

  DestinationError(this.message);
}

// BLoC
class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final DatabaseHelper _databaseHelper;

  DestinationBloc(this._databaseHelper) : super(DestinationInitial()) {
    on<LoadDestinations>(_onLoadDestinations);
    on<AddDestination>(_onAddDestination);
    on<UpdateDestination>(_onUpdateDestination);
    on<DeleteDestination>(_onDeleteDestination);
  }

  Future<void> _onLoadDestinations(
    LoadDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    emit(DestinationLoading());
    try {
      final destinations = await _databaseHelper.getDestinations();
      emit(DestinationLoaded(destinations));
    } catch (e) {
      emit(DestinationError(e.toString()));
    }
  }

  Future<void> _onAddDestination(
    AddDestination event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      final destination = Destination(name: event.name);
      await _databaseHelper.insertDestination(destination);
      add(LoadDestinations());
    } catch (e) {
      emit(DestinationError(e.toString()));
    }
  }

  Future<void> _onUpdateDestination(
    UpdateDestination event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      await _databaseHelper.updateDestination(event.destination);
      add(LoadDestinations());
    } catch (e) {
      emit(DestinationError(e.toString()));
    }
  }

  Future<void> _onDeleteDestination(
    DeleteDestination event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      await _databaseHelper.deleteDestination(event.id);
      add(LoadDestinations());
    } catch (e) {
      emit(DestinationError(e.toString()));
    }
  }
}
