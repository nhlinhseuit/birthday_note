import 'package:dartz/dartz.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/features/events/domain/entities/event.dart';

abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getAllEvents();
  Future<Either<Failure, List<Event>>> getEventsInRange(
      DateTime start, DateTime end);
  Future<Either<Failure, Event>> getEventById(String id);
  Future<Either<Failure, void>> addEvent(Event event);
  Future<Either<Failure, void>> updateEvent(Event event);
  Future<Either<Failure, void>> deleteEvent(String id);
}

