import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

enum CalendarType {
  solar, // Main calendar - shows solar date with lunar date below
  lunar, // Lunar calendar - shows lunar date with month name below
}

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final CalendarType calendarType;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    this.isOutside = false,
    this.calendarType = CalendarType.solar,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime currentDate = DateTime.now();
    final bool isBeforeCurrentDate =
        day.isBefore(currentDate) && !isSameDay(day, currentDate);

    final holiday = LunarCalendarService.getLunarHoliday(day);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isToday ? CupertinoColors.systemBlue.withOpacity(0.1) : null,
        border: isSelected
            ? Border.all(
                color: CupertinoColors.activeBlue,
                width: 2,
              )
            : Border.all(
                color: CupertinoColors.systemGrey5,
                width: 1,
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 24,
            child: Center(
              child: Text(
                _getMainDateText(),
                style: TextStyle(
                  color: holiday != null
                      ? CupertinoColors.systemRed
                      : isBeforeCurrentDate
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Stack(
            children: [
              Text(
                _getSubDateText(),
                style: TextStyle(
                  color: holiday != null
                      ? CupertinoColors.systemRed
                      : isOutside
                          ? CupertinoColors.systemGrey
                          : isBeforeCurrentDate
                              ? CupertinoColors.systemGrey3
                              : CupertinoColors.systemGrey2,
                  fontSize: 10,
                  fontWeight:
                      holiday != null ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMainDateText() {
    final lunarInfo = LunarCalendarService.convertToLunar(day);
    switch (calendarType) {
      case CalendarType.solar:
        return '${day.day}'; // Solar date for main calendar
      case CalendarType.lunar:
        return '${lunarInfo.day}'; // Lunar date for lunar calendar
    }
  }

  String _getSubDateText() {
    final lunarInfo = LunarCalendarService.convertToLunar(day);
    switch (calendarType) {
      case CalendarType.solar:
        return '${lunarInfo.day}'; // Lunar date below solar date
      case CalendarType.lunar:
        // Show month name on day 1 or when the date is outside the current month
        return lunarInfo.day == 1 || isOutside
            ? lunarInfo.monthName
            : ''; // Month name for lunar calendar
    }
  }
}
