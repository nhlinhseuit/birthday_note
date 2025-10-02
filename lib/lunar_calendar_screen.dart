import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:birthday_note/widgets/cupertino_date_picker_widget.dart';
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    Expanded(
                      child: Text(
                        _getVietnameseWeekday(i),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
                    return _buildLunarDayCell(day,
                        isSelected: false, isToday: false);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildLunarDayCell(day,
                        isSelected: true, isToday: false);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildLunarDayCell(day,
                        isSelected: false, isToday: true);
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return _buildLunarDayCell(day,
                        isSelected: false, isToday: false, isOutside: true);
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
                    child: _buildLegendItem(
                      CupertinoIcons.star_fill,
                      CupertinoColors.systemOrange,
                      'Ngày lễ',
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      CupertinoIcons.gift_fill,
                      CupertinoColors.systemPink,
                      'Sinh nhật',
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
              child: _buildDetailedDayView(),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 8,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLunarDayCell(DateTime day,
      {required bool isSelected,
      required bool isToday,
      bool isOutside = false}) {
    final DateTime currentDate = DateTime.now();
    final bool isBeforeCurrentDate =
        day.isBefore(currentDate) && !isSameDay(day, currentDate);

    final lunarInfo = LunarCalendarService.convertToLunar(day);
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
                '${lunarInfo.day}',
                style: TextStyle(
                  color: isBeforeCurrentDate
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
                lunarInfo.day == 1 ? lunarInfo.monthName : '',
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

  Widget _buildDetailedDayView() {
    final selectedDate = _selectedDay ?? DateTime.now();
    final lunarInfo = LunarCalendarService.convertToLunar(selectedDate);
    final holiday = LunarCalendarService.getLunarHoliday(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Âm lịch',
            style: const TextStyle(
              color: CupertinoColors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${lunarInfo.day}',
            style: const TextStyle(
              color: CupertinoColors.systemGreen,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tháng ${lunarInfo.month} năm ${lunarInfo.year}${lunarInfo.isLeapMonth ? " nhuận" : ""}',
            style: const TextStyle(
              color: CupertinoColors.black,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          if (holiday != null) ...[
            const SizedBox(height: 4),
            Text(
              holiday,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getVietnameseWeekday(int index) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return weekdays[index];
  }
}
