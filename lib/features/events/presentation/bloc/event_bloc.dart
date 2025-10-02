import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/events/domain/entities/event.dart';
import 'package:birthday_note/features/events/domain/usecases/add_event.dart';
import 'package:birthday_note/features/events/domain/usecases/delete_event.dart';
import 'package:birthday_note/features/events/domain/usecases/get_all_events.dart';
import 'package:birthday_note/features/events/domain/usecases/get_events_in_range.dart';
import 'package:birthday_note/features/events/domain/usecases/update_event.dart';

part 'event_event.dart';
part 'event_state.dart';

@injectable
class EventBloc extends Bloc<EventEvent, EventState> {
  final GetAllEvents getAllEvents;
  final GetEventsInRange getEventsInRange;
  final AddEvent addEvent;
  final UpdateEvent updateEvent;
  final DeleteEvent deleteEvent;

  EventBloc({
    required this.getAllEvents,
    required this.getEventsInRange,
    required this.addEvent,
    required this.updateEvent,
    required this.deleteEvent,
  }) : super(EventInitial()) {
    on<LoadAllEventsEvent>(_onLoadAllEvents);
    on<LoadEventsInRangeEvent>(_onLoadEventsInRange);
    on<AddEventEvent>(_onAddEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
  }

  Future<void> _onLoadAllEvents(
    LoadAllEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await getAllEvents(NoParams());
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }

  Future<void> _onLoadEventsInRange(
    LoadEventsInRangeEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await getEventsInRange(
      GetEventsInRangeParams(start: event.start, end: event.end),
    );
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }

  Future<void> _onAddEvent(
    AddEventEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await addEvent(event.event);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (_) {
        emit(EventOperationSuccess());
        add(LoadAllEventsEvent());
      },
    );
  }

  Future<void> _onUpdateEvent(
    UpdateEventEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await updateEvent(event.event);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (_) {
        emit(EventOperationSuccess());
        add(LoadAllEventsEvent());
      },
    );
  }

  Future<void> _onDeleteEvent(
    DeleteEventEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await deleteEvent(DeleteEventParams(event.id));
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (_) {
        emit(EventOperationSuccess());
        add(LoadAllEventsEvent());
      },
    );
  }
}

