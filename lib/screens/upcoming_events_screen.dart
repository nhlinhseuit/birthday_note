import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/create_event_screen.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _upcomingEvents = [];
  bool _isLoading = true;
  EventFilter _selectedFilter = EventFilter.all;

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final endDate = DateTime(now.year + 1, 12, 31);
      final allEvents = await EventService.getEventsInRange(now, endDate);

      // Thêm các sự kiện lịch âm có sẵn
      final lunarHolidays = _generateLunarHolidays(now, endDate);

      setState(() {
        _upcomingEvents = [...allEvents, ...lunarHolidays];
        _upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: const Text('Có lỗi xảy ra khi tải sự kiện'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  List<Event> _generateLunarHolidays(DateTime start, DateTime end) {
    final holidays = <Event>[];
    DateTime currentDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!currentDate.isAfter(endDate)) {
      final holiday = LunarCalendarService.getLunarHoliday(currentDate);
      if (holiday != null) {
        holidays.add(Event(
          id: 'lunar_${currentDate.millisecondsSinceEpoch}',
          title: holiday,
          date: currentDate,
          type: EventType.lunar,
          repeatType: RepeatType.yearly,
          createdAt: DateTime.now(),
        ));
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return holidays;
  }

  List<Event> _getFilteredEvents() {
    switch (_selectedFilter) {
      case EventFilter.myEvents:
        return _upcomingEvents
            .where((event) => event.id.startsWith('lunar_') == false)
            .toList();
      case EventFilter.lunarHolidays:
        return _upcomingEvents
            .where((event) => event.id.startsWith('lunar_'))
            .toList();
      case EventFilter.all:
      default:
        return _upcomingEvents;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text(
          'Sự kiện sắp tới',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.black,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _loadUpcomingEvents,
              child: const Icon(
                CupertinoIcons.refresh,
                color: CupertinoColors.systemBlue,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final newEvent = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );

                if (newEvent != null) {
                  _loadUpcomingEvents();
                }
              },
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          // Filter buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterButton(
                    EventFilter.all,
                    'Tất cả',
                    CupertinoIcons.list_bullet,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    EventFilter.myEvents,
                    'Của tôi',
                    CupertinoIcons.person,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    EventFilter.lunarHolidays,
                    'Lịch âm',
                    CupertinoIcons.calendar,
                  ),
                ),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CupertinoActivityIndicator(),
                  )
                : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(EventFilter filter, String title, IconData icon) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.1)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.label,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final filteredEvents = _getFilteredEvents();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 80,
              color: CupertinoColors.systemGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == EventFilter.myEvents
                  ? 'Chưa có sự kiện nào của bạn'
                  : 'Không có sự kiện nào',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút + để tạo sự kiện mới',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final daysUntil = event.date.difference(DateTime.now()).inDays;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(16),
            onPressed: () {
              // Có thể mở chi tiết sự kiện hoặc edit
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getEventColor(event),
                  ),
                  child: Icon(
                    _getEventIcon(event),
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUtils.formatDateToVietnamese(event.date),
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LunarCalendarService.getLunarInfo(event.date),
                        style: TextStyle(
                          color: CupertinoColors.systemGrey.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getEventColor(event).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _getEventColor(event)),
                            ),
                            child: Text(
                              _getEventTypeText(event),
                              style: TextStyle(
                                color: _getEventColor(event),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: daysUntil <= 7
                                  ? CupertinoColors.systemRed.withOpacity(0.1)
                                  : CupertinoColors.systemBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: daysUntil <= 7
                                    ? CupertinoColors.systemRed
                                    : CupertinoColors.systemBlue,
                              ),
                            ),
                            child: Text(
                              daysUntil == 0
                                  ? 'Hôm nay'
                                  : daysUntil == 1
                                      ? 'Ngày mai'
                                      : daysUntil < 0
                                          ? 'Đã qua ${-daysUntil} ngày'
                                          : 'Còn $daysUntil ngày',
                              style: TextStyle(
                                color: daysUntil <= 7
                                    ? CupertinoColors.systemRed
                                    : CupertinoColors.systemBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
        );
      },
    );
  }

  Color _getEventColor(Event event) {
    if (event.id.startsWith('lunar_')) {
      return CupertinoColors.systemOrange; // Sự kiện lịch âm có sẵn
    }

    switch (event.type) {
      case EventType.solar:
        return CupertinoColors.systemGreen;
      case EventType.lunar:
        return CupertinoColors.systemPurple;
    }
  }

  IconData _getEventIcon(Event event) {
    if (event.id.startsWith('lunar_')) {
      return CupertinoIcons.calendar;
    }

    switch (event.type) {
      case EventType.solar:
        return CupertinoIcons.calendar_today;
      case EventType.lunar:
        return CupertinoIcons.calendar_badge_plus;
    }
  }

  String _getEventTypeText(Event event) {
    if (event.id.startsWith('lunar_')) {
      return 'Lịch âm';
    }

    switch (event.type) {
      case EventType.solar:
        return 'Lịch dương';
      case EventType.lunar:
        return 'Lịch âm';
    }
  }
}

enum EventFilter {
  all,
  myEvents,
  lunarHolidays,
}
