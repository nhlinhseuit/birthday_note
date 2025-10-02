part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class LoadAllEventsEvent extends EventEvent {}

class LoadEventsInRangeEvent extends EventEvent {
  final DateTime start;
  final DateTime end;

  const LoadEventsInRangeEvent({
    required this.start,
    required this.end,
  });

  @override
  List<Object> get props => [start, end];
}

class AddEventEvent extends EventEvent {
  final Event event;

  const AddEventEvent(this.event);

  @override
  List<Object> get props => [event];
}

class UpdateEventEvent extends EventEvent {
  final Event event;

  const UpdateEventEvent(this.event);

  @override
  List<Object> get props => [event];
}

class DeleteEventEvent extends EventEvent {
  final String id;

  const DeleteEventEvent(this.id);

  @override
  List<Object> get props => [id];
}

