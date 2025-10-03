import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/create_event_screen.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/widgets/swipeable_event_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _upcomingEvents = [];
  bool _isLoading = true;
  EventFilter _selectedFilter = EventFilter.myEvents;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedMonth; // null means no month filter

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        // Sort by date (ascending - earliest first)
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
    List<Event> filteredEvents;

    // Apply filter first
    switch (_selectedFilter) {
      case EventFilter.myEvents:
        filteredEvents = _upcomingEvents
            .where((event) => event.id.startsWith('lunar_') == false)
            .toList();
        break;
      case EventFilter.lunarHolidays:
        filteredEvents = _upcomingEvents
            .where((event) => event.id.startsWith('lunar_'))
            .toList();
        break;
      case EventFilter.all:
      default:
        filteredEvents = _upcomingEvents;
        break;
    }

    // Apply search filter if search query is not empty
    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents
          .where((event) =>
              event.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply month filter if a month is selected
    if (_selectedMonth != null) {
      filteredEvents = filteredEvents
          .where((event) => event.date.month == _selectedMonth)
          .toList();
    }

    return filteredEvents;
  }

  // Group events by year and create a list with separators
  List<dynamic> _getEventsWithSeparators() {
    final filteredEvents = _getFilteredEvents();
    if (filteredEvents.isEmpty) return [];

    final currentYear = DateTime.now().year;
    final eventsByYear = <int, List<Event>>{};

    // Group events by year
    for (final event in filteredEvents) {
      final year = event.date.year;
      eventsByYear.putIfAbsent(year, () => []).add(event);
    }

    // Create list with separators
    final result = <dynamic>[];
    final sortedYears = eventsByYear.keys.toList()..sort();

    for (final year in sortedYears) {
      // Add year separator
      result.add({
        'type': 'separator',
        'year': year,
        'isCurrentYear': year == currentYear,
      });

      // Add events for this year
      final yearEvents = eventsByYear[year]!;
      for (final event in yearEvents) {
        result.add({
          'type': 'event',
          'event': event,
        });
      }
    }

    return result;
  }

  void _showMonthFilterModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _MonthFilterModal(
        selectedMonth: _selectedMonth,
        onMonthSelected: (month) {
          setState(() {
            _selectedMonth = month;
          });
        },
      ),
    );
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
              _loadUpcomingEvents();
            }
          },
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.systemBlue,
          ),
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

          // Search bar with filter button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Tìm kiếm sự kiện...',
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.transparent),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        // Hide keyboard when search is submitted
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed: _showMonthFilterModal,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedMonth != null
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedMonth != null
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey4,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: _selectedMonth != null
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Events list
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Hide keyboard when tapping on events list
                FocusScope.of(context).unfocus();
              },
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : _buildEventsList(),
            ),
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
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: Center(
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
                  _searchQuery.isNotEmpty
                      ? 'Không tìm thấy sự kiện nào'
                      : _selectedMonth != null
                          ? 'Không có sự kiện nào trong tháng $_selectedMonth'
                          : (_selectedFilter == EventFilter.myEvents
                              ? 'Chưa có sự kiện nào của bạn'
                              : 'Không có sự kiện nào'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                if (_searchQuery.isEmpty)
                  Text(
                    'Nhấn nút + để tạo sự kiện mới',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final itemsWithSeparators = _getEventsWithSeparators();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemsWithSeparators.length,
      itemBuilder: (context, index) {
        final item = itemsWithSeparators[index];

        if (item['type'] == 'separator') {
          return _buildYearSeparator(item['year'], item['isCurrentYear']);
        } else {
          final event = item['event'] as Event;
          return SwipeableEventItem(
            event: event,
            onEventDeleted: _loadUpcomingEvents,
            onEventUpdated: _loadUpcomingEvents,
          );
        }
      },
    );
  }

  Widget _buildYearSeparator(int year, bool isCurrentYear) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentYear
            ? CupertinoColors.systemBlue.withOpacity(0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentYear
              ? CupertinoColors.systemBlue.withOpacity(0.3)
              : CupertinoColors.systemGrey4,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 16,
            color: isCurrentYear
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 8),
          Text(
            isCurrentYear ? 'Năm nay ($year)' : 'Năm $year',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCurrentYear
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

enum EventFilter {
  all,
  myEvents,
  lunarHolidays,
}

class _MonthFilterModal extends StatefulWidget {
  final int? selectedMonth;
  final Function(int?) onMonthSelected;

  const _MonthFilterModal({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  State<_MonthFilterModal> createState() => _MonthFilterModalState();
}

class _MonthFilterModalState extends State<_MonthFilterModal> {
  late int? _tempSelectedMonth;
  final List<String> _monthNames = [
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
    'Tháng 12',
  ];

  @override
  void initState() {
    super.initState();
    _tempSelectedMonth = widget.selectedMonth;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text(
          'Lọc theo tháng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 16,
            ),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            widget.onMonthSelected(_tempSelectedMonth);
            Navigator.pop(context);
          },
          child: const Text(
            'Lọc',
            style: TextStyle(
              color: CupertinoColors.systemBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Clear filter option
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  setState(() {
                    _tempSelectedMonth = null;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _tempSelectedMonth == null
                        ? CupertinoColors.systemBlue.withOpacity(0.1)
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _tempSelectedMonth == null
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.systemGrey4,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.clear_circled,
                        color: _tempSelectedMonth == null
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tất cả tháng',
                        style: TextStyle(
                          color: _tempSelectedMonth == null
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Month options
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _monthNames.length,
                itemBuilder: (context, index) {
                  final monthNumber = index + 1;
                  final isSelected = _tempSelectedMonth == monthNumber;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _tempSelectedMonth = monthNumber;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CupertinoColors.systemBlue.withOpacity(0.1)
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemGrey4,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey5,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      CupertinoIcons.checkmark,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _monthNames[index],
                              style: TextStyle(
                                color: isSelected
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
