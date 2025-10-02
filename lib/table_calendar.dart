// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: avoid_print

import 'package:birthday_note/utils/app_utils.dart';
import 'package:birthday_note/utils/utils.dart' as utils;
import 'package:birthday_note/widgets/calendar_day_cell.dart';
import 'package:birthday_note/widgets/cupertino_date_picker_widget.dart';
import 'package:birthday_note/widgets/detailed_day_view.dart';
import 'package:birthday_note/widgets/legend_item.dart';
import 'package:birthday_note/widgets/weekday_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TableEventsExample extends StatefulWidget {
  const TableEventsExample({super.key});

  @override
  State<TableEventsExample> createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<utils.Event>> _selectedEvents;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<utils.Event> _getEventsForDay(DateTime day) {
    return utils.kEvents[day] ?? [];
  }

  List<utils.Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = utils.daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  Future<void> _selectDate() async {
    await CupertinoDatePickerWidget.showSolarDatePicker(
      context: context,
      initialDate: _focusedDay,
      onDateSelected: (DateTime selectedDate) {
        setState(() {
          _focusedDay = selectedDate;
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
          onTap: _selectDate,
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
                  "Lịch - ${AppUtils.formatDateToVietnamese(_focusedDay)}",
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
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ),
      child: _buildCalendarBody(),
    );
  }

  Widget _buildCalendarBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Custom Vietnamese weekday header
          const WeekdayHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TableCalendar<utils.Event>(
              firstDay: utils.kFirstDay,
              lastDay: utils.kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 50,
              daysOfWeekHeight: 0,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(
                  color: CupertinoColors.label,
                ),
                todayTextStyle: const TextStyle(
                  color: CupertinoColors.label,
                ),
                selectedTextStyle: const TextStyle(
                  color: CupertinoColors.white,
                ),
                weekendTextStyle: const TextStyle(
                  color: CupertinoColors.systemRed,
                ),
                outsideTextStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
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
              availableCalendarFormats: const {
                CalendarFormat.month: 'Tháng',
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return CalendarDayCell(
                    day: day,
                    isSelected: false,
                    isToday: false,
                    calendarType: CalendarType.solar,
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return CalendarDayCell(
                    day: day,
                    isSelected: true,
                    isToday: false,
                    calendarType: CalendarType.solar,
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return CalendarDayCell(
                    day: day,
                    isSelected: false,
                    isToday: true,
                    calendarType: CalendarType.solar,
                  );
                },
                outsideBuilder: (context, day, focusedDay) {
                  return CalendarDayCell(
                    day: day,
                    isSelected: false,
                    isToday: false,
                    isOutside: true,
                    calendarType: CalendarType.solar,
                  );
                },
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 10,
                      right: 6,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
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
              showSolarCalendar: true,
              showLunarCalendar: true,
            ),
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<List<utils.Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              if (value.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Không có sự kiện nào',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (int index = 0; index < value.length; index++)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(16),
                        onPressed: () => print('${value[index]}'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${value[index]}',
                                style: const TextStyle(
                                  color: CupertinoColors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: CupertinoColors.systemGrey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
