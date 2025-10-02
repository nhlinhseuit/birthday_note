import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/core/usecases/usecase.dart';
import 'package:birthday_note/features/lunar_calendar/domain/repositories/lunar_calendar_repository.dart';

@lazySingleton
class GetLunarHoliday implements UseCase<String?, GetLunarHolidayParams> {
  final LunarCalendarRepository repository;

  GetLunarHoliday(this.repository);

  @override
  Future<Either<Failure, String?>> call(GetLunarHolidayParams params) async {
    return Future.value(repository.getLunarHoliday(params.solarDate));
  }
}

class GetLunarHolidayParams extends Equatable {
  final DateTime solarDate;

  const GetLunarHolidayParams(this.solarDate);

  @override
  List<Object> get props => [solarDate];
}

