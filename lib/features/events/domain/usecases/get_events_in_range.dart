import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/events/domain/entities/event.dart';
import 'package:birthday_note/features/events/domain/repositories/event_repository.dart';

@lazySingleton
class GetEventsInRange implements UseCase<List<Event>, GetEventsInRangeParams> {
  final EventRepository repository;

  GetEventsInRange(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(
      GetEventsInRangeParams params) async {
    return await repository.getEventsInRange(params.start, params.end);
  }
}

class GetEventsInRangeParams extends Equatable {
  final DateTime start;
  final DateTime end;

  const GetEventsInRangeParams({
    required this.start,
    required this.end,
  });

  @override
  List<Object> get props => [start, end];
}

