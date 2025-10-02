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
  // Dữ liệu lịch âm từ năm 1900-2100 (simplified)
  static const Map<int, int> _lunarMonths = {
    1: 29,
    2: 30,
    3: 29,
    4: 30,
    5: 29,
    6: 30,
    7: 29,
    8: 30,
    9: 29,
    10: 30,
    11: 29,
    12: 30
  };

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

  // Chuyển đổi từ ngày dương sang ngày âm (simplified algorithm)
  static LunarDate convertToLunar(DateTime solarDate) {
    // Đây là thuật toán đơn giản, trong thực tế cần thuật toán phức tạp hơn
    // hoặc sử dụng dữ liệu lookup table

    int lunarYear = solarDate.year;
    int lunarMonth = ((solarDate.month - 1) % 12) + 1;
    int lunarDay = ((solarDate.day - 1) % 30) + 1;

    // Điều chỉnh để có dữ liệu hợp lý hơn
    if (lunarMonth == 2 && lunarDay > 29) {
      lunarDay = 29;
    } else if ([4, 6, 9, 11].contains(lunarMonth) && lunarDay > 30) {
      lunarDay = 30;
    }

    return LunarDate(
      day: lunarDay,
      month: lunarMonth,
      year: lunarYear,
      monthName: _monthNames[lunarMonth],
      dayName: _dayNames[lunarDay],
    );
  }

  // Lấy thông tin lịch âm cho một ngày
  static String getLunarInfo(DateTime solarDate) {
    final lunar = convertToLunar(solarDate);
    return '${lunar.dayName} ngày ${lunar.day} tháng ${lunar.monthName} năm ${lunar.year}';
  }

  // Lấy tên tháng âm lịch
  static String getLunarMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return _monthNames[month];
    }
    return 'Tháng $month';
  }

  // Lấy tên ngày âm lịch
  static String getLunarDayName(int day) {
    if (day >= 1 && day <= 30) {
      return _dayNames[day];
    }
    return 'Ngày $day';
  }

  // Kiểm tra ngày lễ âm lịch
  static String? getLunarHoliday(DateTime solarDate) {
    final lunar = convertToLunar(solarDate);

    // Một số ngày lễ âm lịch phổ biến
    if (lunar.month == 1 && lunar.day == 1) {
      return 'Tết Nguyên Đán';
    } else if (lunar.month == 1 && lunar.day == 15) {
      return 'Tết Nguyên Tiêu';
    } else if (lunar.month == 3 && lunar.day == 3) {
      return 'Tết Hàn Thực';
    } else if (lunar.month == 4 && lunar.day == 8) {
      return 'Lễ Phật Đản';
    } else if (lunar.month == 5 && lunar.day == 5) {
      return 'Tết Đoan Ngọ';
    } else if (lunar.month == 7 && lunar.day == 7) {
      return 'Tết Thất Tịch';
    } else if (lunar.month == 7 && lunar.day == 15) {
      return 'Tết Trung Nguyên';
    } else if (lunar.month == 8 && lunar.day == 15) {
      return 'Tết Trung Thu';
    } else if (lunar.month == 9 && lunar.day == 9) {
      return 'Tết Trùng Cửu';
    } else if (lunar.month == 10 && lunar.day == 10) {
      return 'Tết Thường Tân';
    } else if (lunar.month == 12 && lunar.day == 8) {
      return 'Tết Lạp Bát';
    } else if (lunar.month == 12 && lunar.day == 23) {
      return 'Tết Táo Quân';
    }

    return null;
  }

  // Lấy số ngày trong tháng âm lịch
  static int getLunarMonthDays(int year, int month) {
    // Simplified - trong thực tế cần tính toán chính xác hơn
    return _lunarMonths[month] ?? 30;
  }
}
