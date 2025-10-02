import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/lunar_calendar/domain/entities/lunar_date.dart';
import 'package:birthday_note/features/lunar_calendar/domain/repositories/lunar_calendar_repository.dart';

@lazySingleton
class ConvertToLunar implements UseCase<LunarDate, ConvertToLunarParams> {
  final LunarCalendarRepository repository;

  ConvertToLunar(this.repository);

  @override
  Future<Either<Failure, LunarDate>> call(ConvertToLunarParams params) async {
    return Future.value(repository.convertToLunar(params.solarDate));
  }
}

class ConvertToLunarParams extends Equatable {
  final DateTime solarDate;

  const ConvertToLunarParams(this.solarDate);

  @override
  List<Object> get props => [solarDate];
}

