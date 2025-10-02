import 'package:equatable/equatable.dart';

class LunarDate extends Equatable {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String dayName;
  final bool isLeapMonth;

  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.dayName,
    this.isLeapMonth = false,
  });

  @override
  List<Object?> get props => [
        day,
        month,
        year,
        monthName,
        dayName,
        isLeapMonth,
      ];

  @override
  String toString() {
    return 'Ngày $day tháng $month năm $year ($monthName)';
  }
}

