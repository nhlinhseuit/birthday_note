// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: avoid_print

import 'package:birthday_note/screens/create_event_screen.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:birthday_note/widgets/calendar_day_cell.dart';
import 'package:birthday_note/widgets/cupertino_date_picker_widget.dart';
import 'package:birthday_note/widgets/detailed_day_view.dart';
import 'package:birthday_note/widgets/event_list_widget.dart';
import 'package:birthday_note/widgets/legend_item.dart';
import 'package:birthday_note/widgets/weekday_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Helper function to check if two dates are the same day
bool isSameDay(DateTime? date1, DateTime date2) {
  if (date1 == null) return false;
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class TableEventsExample extends StatefulWidget {
  const TableEventsExample({super.key});

  @override
  State<TableEventsExample> createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _loadEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh events when returning to this screen
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await EventService.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      if (event.type == EventType.lunar) {
        // For lunar events, check if the lunar date matches
        final eventLunar = LunarCalendarService.convertToLunar(event.date);
        final dayLunar = LunarCalendarService.convertToLunar(day);

        if (event.repeatType == RepeatType.yearly) {
          // Yearly repeat: check month and day
          return eventLunar.month == dayLunar.month &&
              eventLunar.day == dayLunar.day;
        } else {
          // No repeat: check exact date
          return eventLunar.month == dayLunar.month &&
              eventLunar.day == dayLunar.day &&
              eventLunar.year == dayLunar.year;
        }
      } else {
        // For solar events, check solar date
        if (event.repeatType == RepeatType.yearly) {
          return event.date.month == day.month && event.date.day == day.day;
        } else {
          return isSameDay(event.date, day);
        }
      }
    }).toList();
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
  }

  Future<void> _selectDate() async {
    await CupertinoDatePickerWidget.showSolarDatePicker(
      context: context,
      initialDate: _focusedDay,
      minimumYear: 2020,
      maximumYear: 2030,
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
          onPressed: () async {
            final newEvent = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const CreateEventScreen(),
              ),
            );

            if (newEvent != null) {
              _loadEvents();
            }
          },
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
            child: TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
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
                defaultTextStyle: TextStyle(
                  color: CupertinoColors.label,
                ),
                todayTextStyle: TextStyle(
                  color: CupertinoColors.label,
                ),
                selectedTextStyle: TextStyle(
                  color: CupertinoColors.white,
                ),
                weekendTextStyle: TextStyle(
                  color: CupertinoColors.systemRed,
                ),
                outsideTextStyle: TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
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
                  final isOutside = day.month != focusedDay.month;
                  return CalendarDayCell(
                    day: day,
                    isSelected: false,
                    isToday: false,
                    isOutside: isOutside,
                    calendarType: CalendarType.solar,
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final isOutside = day.month != focusedDay.month;
                  return CalendarDayCell(
                    day: day,
                    isSelected: true,
                    isToday: false,
                    isOutside: isOutside,
                    calendarType: CalendarType.solar,
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final isOutside = day.month != focusedDay.month;
                  return CalendarDayCell(
                    day: day,
                    isSelected: false,
                    isToday: true,
                    isOutside: isOutside,
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
                    return const Positioned(
                      bottom: 8,
                      right: 6,
                      child: Icon(
                        Icons.cake_rounded,
                        size: 12,
                        color: CupertinoColors.systemPurple,
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
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CupertinoColors.systemRed),
                        ),
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: CupertinoColors.systemRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Ngày lễ',
                          style: TextStyle(
                            color: CupertinoColors.label,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(
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
          // Hiển thị sự kiện cho ngày được chọn
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CupertinoColors.systemGrey4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sự kiện',
                  style: TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                EventListWidget(
                  events: _getEventsForDay(_selectedDay ?? DateTime.now()),
                  isLoading: _isLoading,
                  onEventDeleted: _loadEvents,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
