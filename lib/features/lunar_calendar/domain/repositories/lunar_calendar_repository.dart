import 'package:dartz/dartz.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/features/lunar_calendar/domain/entities/lunar_date.dart';

abstract class LunarCalendarRepository {
  Either<Failure, LunarDate> convertToLunar(DateTime solarDate);
  Either<Failure, String?> getLunarHoliday(DateTime solarDate);
  Either<Failure, String> getLunarInfo(DateTime solarDate);
}

