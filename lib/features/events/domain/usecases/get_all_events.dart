import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/events/domain/entities/event.dart';
import 'package:birthday_note/features/events/domain/repositories/event_repository.dart';

@lazySingleton
class GetAllEvents implements UseCase<List<Event>, NoParams> {
  final EventRepository repository;

  GetAllEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(NoParams params) async {
    return await repository.getAllEvents();
  }
}

