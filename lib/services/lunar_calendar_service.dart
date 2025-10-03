import 'accurate_lunar_calendar_service.dart';

class LunarDate {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String dayName;
  final bool isLeapMonth;

  LunarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.dayName,
    this.isLeapMonth = false,
  });

  @override
  String toString() {
    return 'Ngày $day tháng $month năm $year ($monthName)';
  }
}

class LunarCalendarService {
  // Use accurate lunar calendar service with Hồ Ngọc Đức algorithm
  static LunarDate convertToLunar(DateTime solarDate) {
    final lunar = AccurateLunarCalendarService.convertToLunar(solarDate);
    return LunarDate(
      day: lunar['day'],
      month: lunar['month'],
      year: lunar['year'],
      monthName: AccurateLunarCalendarService.getLunarMonthName(lunar['month']),
      dayName: AccurateLunarCalendarService.getLunarDayName(lunar['day']),
      isLeapMonth: lunar['leap'],
    );
  }

  // Lấy thông tin lịch âm cho một ngày
  static String getLunarInfo(DateTime solarDate) {
    return AccurateLunarCalendarService.getLunarInfo(solarDate);
  }

  // Lấy tên tháng âm lịch
  static String getLunarMonthName(int month) {
    return AccurateLunarCalendarService.getLunarMonthName(month);
  }

  // Lấy tên ngày âm lịch
  static String getLunarDayName(int day) {
    return AccurateLunarCalendarService.getLunarDayName(day);
  }

  // Kiểm tra ngày lễ âm lịch
  static String? getLunarHoliday(DateTime solarDate) {
    return AccurateLunarCalendarService.getLunarHoliday(solarDate);
  }

  // Lấy số ngày trong tháng âm lịch
  static int getLunarMonthDays(int year, int month) {
    return AccurateLunarCalendarService.getLunarMonthDays(year, month);
  }
}
