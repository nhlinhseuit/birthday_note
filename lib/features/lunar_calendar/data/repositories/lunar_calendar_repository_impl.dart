import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/core/error/failures.dart';
import 'package:birthday_note/features/lunar_calendar/domain/entities/lunar_date.dart';
import 'package:birthday_note/features/lunar_calendar/domain/repositories/lunar_calendar_repository.dart';

@LazySingleton(as: LunarCalendarRepository)
class LunarCalendarRepositoryImpl implements LunarCalendarRepository {
  static const List<String> _monthNames = [
    '',
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12'
  ];

  static const List<String> _dayNames = [
    '',
    'Một',
    'Hai',
    'Ba',
    'Bốn',
    'Năm',
    'Sáu',
    'Bảy',
    'Tám',
    'Chín',
    'Mười',
    'Mười một',
    'Mười hai',
    'Mười ba',
    'Mười bốn',
    'Mười lăm',
    'Mười sáu',
    'Mười bảy',
    'Mười tám',
    'Mười chín',
    'Hai mươi',
    'Hai mốt',
    'Hai hai',
    'Hai ba',
    'Hai tư',
    'Hai lăm',
    'Hai sáu',
    'Hai bảy',
    'Hai tám',
    'Hai chín',
    'Ba mươi'
  ];

  @override
  Either<Failure, LunarDate> convertToLunar(DateTime solarDate) {
    try {
      int lunarYear = solarDate.year;
      int lunarMonth = ((solarDate.month - 1) % 12) + 1;
      int lunarDay = ((solarDate.day - 1) % 30) + 1;

      if (lunarMonth == 2 && lunarDay > 29) {
        lunarDay = 29;
      } else if ([4, 6, 9, 11].contains(lunarMonth) && lunarDay > 30) {
        lunarDay = 30;
      }

      return Right(LunarDate(
        day: lunarDay,
        month: lunarMonth,
        year: lunarYear,
        monthName: _monthNames[lunarMonth],
        dayName: _dayNames[lunarDay],
      ));
    } catch (e) {
      return Left(CacheFailure('Failed to convert to lunar: ${e.toString()}'));
    }
  }

  @override
  Either<Failure, String?> getLunarHoliday(DateTime solarDate) {
    try {
      final lunarResult = convertToLunar(solarDate);
      return lunarResult.fold(
        (failure) => Left(failure),
        (lunar) {
          if (lunar.month == 1 && lunar.day == 1) {
            return const Right('Tết Nguyên Đán');
          } else if (lunar.month == 1 && lunar.day == 15) {
            return const Right('Tết Nguyên Tiêu');
          } else if (lunar.month == 3 && lunar.day == 3) {
            return const Right('Tết Hàn Thực');
          } else if (lunar.month == 4 && lunar.day == 8) {
            return const Right('Lễ Phật Đản');
          } else if (lunar.month == 5 && lunar.day == 5) {
            return const Right('Tết Đoan Ngọ');
          } else if (lunar.month == 7 && lunar.day == 7) {
            return const Right('Tết Thất Tịch');
          } else if (lunar.month == 7 && lunar.day == 15) {
            return const Right('Tết Trung Nguyên');
          } else if (lunar.month == 8 && lunar.day == 15) {
            return const Right('Tết Trung Thu');
          } else if (lunar.month == 9 && lunar.day == 9) {
            return const Right('Tết Trùng Cửu');
          } else if (lunar.month == 10 && lunar.day == 10) {
            return const Right('Tết Thường Tân');
          } else if (lunar.month == 12 && lunar.day == 8) {
            return const Right('Tết Lạp Bát');
          } else if (lunar.month == 12 && lunar.day == 23) {
            return const Right('Tết Táo Quân');
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get lunar holiday: ${e.toString()}'));
    }
  }

  @override
  Either<Failure, String> getLunarInfo(DateTime solarDate) {
    try {
      final lunarResult = convertToLunar(solarDate);
      return lunarResult.fold(
        (failure) => Left(failure),
        (lunar) => Right(
            '${lunar.dayName} ngày ${lunar.day} tháng ${lunar.monthName} năm ${lunar.year}'),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get lunar info: ${e.toString()}'));
    }
  }
}

