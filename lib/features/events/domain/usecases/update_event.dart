import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/events/domain/entities/event.dart';
import 'package:birthday_note/features/events/domain/repositories/event_repository.dart';

@lazySingleton
class UpdateEvent implements UseCase<void, Event> {
  final EventRepository repository;

  UpdateEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(Event event) async {
    return await repository.updateEvent(event);
  }
}

