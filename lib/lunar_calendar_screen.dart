import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:birthday_note/widgets/calendar_day_cell.dart';
import 'package:birthday_note/widgets/cupertino_date_picker_widget.dart';
import 'package:birthday_note/widgets/detailed_day_view.dart';
import 'package:birthday_note/widgets/legend_item.dart';
import 'package:birthday_note/widgets/weekday_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

class LunarCalendarScreen extends StatefulWidget {
  const LunarCalendarScreen({super.key});

  @override
  State<LunarCalendarScreen> createState() => _LunarCalendarScreenState();
}

class _LunarCalendarScreenState extends State<LunarCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _selectLunarDate() async {
    final currentLunar = LunarCalendarService.convertToLunar(_focusedDay);

    await CupertinoDatePickerWidget.showLunarDatePicker(
      context: context,
      initialDay: currentLunar.day,
      initialMonth: currentLunar.month,
      initialYear: currentLunar.year,
      onDateSelected: (int day, int month, int year) {
        setState(() {
          _focusedDay = DateTime(year, month, day);
          _selectedDay = _focusedDay;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: GestureDetector(
          onTap: _selectLunarDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Lịch Âm - ${AppUtils.formatDateToVietnamese(_focusedDay)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Vietnamese weekday header
            const WeekdayHeader(),
            // Calendar với thông tin lịch âm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TableCalendar<dynamic>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rowHeight: 50,
                daysOfWeekHeight: 0,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle:
                      const TextStyle(color: CupertinoColors.label),
                  todayTextStyle: const TextStyle(color: CupertinoColors.label),
                  selectedTextStyle:
                      const TextStyle(color: CupertinoColors.white),
                  weekendTextStyle:
                      const TextStyle(color: CupertinoColors.systemRed),
                  outsideTextStyle:
                      const TextStyle(color: CupertinoColors.systemGrey),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    color: CupertinoColors.label,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: Icon(
                    CupertinoIcons.chevron_left,
                    color: CupertinoColors.label,
                  ),
                  rightChevronIcon: Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.label,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return CalendarDayCell(
                      day: day,
                      isSelected: false,
                      isToday: false,
                      calendarType: CalendarType.lunar,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return CalendarDayCell(
                      day: day,
                      isSelected: true,
                      isToday: false,
                      calendarType: CalendarType.lunar,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return CalendarDayCell(
                      day: day,
                      isSelected: false,
                      isToday: true,
                      calendarType: CalendarType.lunar,
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return CalendarDayCell(
                      day: day,
                      isSelected: false,
                      isToday: false,
                      isOutside: true,
                      calendarType: CalendarType.lunar,
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),

            const SizedBox(height: 8.0),

            // Instruction/Legend box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LegendItem(
                      icon: CupertinoIcons.star_fill,
                      color: CupertinoColors.systemOrange,
                      label: 'Ngày lễ',
                    ),
                  ),
                  Expanded(
                    child: LegendItem(
                      icon: Icons.cake_rounded,
                      color: CupertinoColors.systemPurple,
                      label: 'Sinh nhật',
                    ),
                  ),
                ],
              ),
            ),

            // Hiển thị thông tin ngày được chọn
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: DetailedDayView(
                selectedDate: _selectedDay ?? DateTime.now(),
                showSolarCalendar: false,
                showLunarCalendar: true,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
