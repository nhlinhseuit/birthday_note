import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/features/events/data/datasources/event_local_data_source.dart';
import 'package:birthday_note/features/events/data/models/event_model.dart';
import 'package:birthday_note/features/events/domain/entities/event.dart';
import 'package:birthday_note/features/events/domain/repositories/event_repository.dart';

@LazySingleton(as: EventRepository)
class EventRepositoryImpl implements EventRepository {
  final EventLocalDataSource localDataSource;

  EventRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Event>>> getAllEvents() async {
    try {
      final events = await localDataSource.getAllEvents();
      return Right(events);
    } catch (e) {
      return Left(CacheFailure('Failed to get events: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsInRange(
      DateTime start, DateTime end) async {
    try {
      final allEvents = await localDataSource.getAllEvents();
      final filteredEvents = allEvents.where((event) {
        return event.date.isAfter(start.subtract(const Duration(days: 1))) &&
            event.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
      return Right(filteredEvents);
    } catch (e) {
      return Left(CacheFailure('Failed to get events in range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    try {
      final events = await localDataSource.getAllEvents();
      final event = events.firstWhere((e) => e.id == id);
      return Right(event);
    } catch (e) {
      return Left(CacheFailure('Event not found'));
    }
  }

  @override
  Future<Either<Failure, void>> addEvent(Event event) async {
    try {
      final eventModel = EventModel.fromEntity(event);
      await localDataSource.cacheEvent(eventModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add event: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEvent(Event event) async {
    try {
      final eventModel = EventModel.fromEntity(event);
      await localDataSource.updateCachedEvent(eventModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update event: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    try {
      await localDataSource.deleteEvent(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete event: ${e.toString()}'));
    }
  }
}

