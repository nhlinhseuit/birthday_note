import 'package:birthday_note/core/di/injection.dart';
import 'package:birthday_note/features/lunar_calendar/domain/entities/lunar_date.dart';
import 'package:birthday_note/features/lunar_calendar/domain/repositories/lunar_calendar_repository.dart';

/// Helper class for quick lunar calendar conversions without BLoC
/// Useful for UI that needs immediate synchronous results
class LunarCalendarHelper {
  static final _repository = getIt<LunarCalendarRepository>();

  static LunarDate convertToLunar(DateTime solarDate) {
    final result = _repository.convertToLunar(solarDate);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (lunarDate) => lunarDate,
    );
  }

  static String? getLunarHoliday(DateTime solarDate) {
    final result = _repository.getLunarHoliday(solarDate);
    return result.fold(
      (failure) => null,
      (holiday) => holiday,
    );
  }

  static String getLunarInfo(DateTime solarDate) {
    final result = _repository.getLunarInfo(solarDate);
    return result.fold(
      (failure) => '',
      (info) => info,
    );
  }
}

