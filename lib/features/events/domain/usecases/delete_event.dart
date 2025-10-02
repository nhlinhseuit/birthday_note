import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/events/domain/repositories/event_repository.dart';

@lazySingleton
class DeleteEvent implements UseCase<void, DeleteEventParams> {
  final EventRepository repository;

  DeleteEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteEventParams params) async {
    return await repository.deleteEvent(params.id);
  }
}

class DeleteEventParams extends Equatable {
  final String id;

  const DeleteEventParams(this.id);

  @override
  List<Object> get props => [id];
}

