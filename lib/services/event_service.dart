import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';

class EventService {
  static const String _eventsKey = 'birthday_events';

  // Lưu danh sách events
  static Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((event) => event.toJson()).toList();
    await prefs.setString(_eventsKey, jsonEncode(eventsJson));
  }

  // Lấy danh sách events
  static Future<List<Event>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKey);

    if (eventsString == null) {
      return [];
    }

    try {
      final List<dynamic> eventsJson = jsonDecode(eventsString);
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Thêm event mới
  static Future<void> addEvent(Event event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  // Cập nhật event
  static Future<void> updateEvent(Event event) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }

  // Xóa event
  static Future<void> deleteEvent(String eventId) async {
    final events = await getEvents();
    events.removeWhere((event) => event.id == eventId);
    await saveEvents(events);
  }

  // Xóa tất cả events
  static Future<void> deleteAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
  }

  // Lấy events cho một ngày cụ thể
  static Future<List<Event>> getEventsForDate(DateTime date) async {
    final allEvents = await getEvents();
    final eventsForDate = <Event>[];

    for (final event in allEvents) {
      if (_shouldShowEventOnDate(event, date)) {
        eventsForDate.add(event);
      }
    }

    return eventsForDate;
  }

  // Kiểm tra xem event có nên hiển thị trên ngày này không
  static bool _shouldShowEventOnDate(Event event, DateTime date) {
    // Nếu không lặp lại, chỉ hiển thị đúng ngày
    if (event.repeatType == RepeatType.none) {
      return isSameDay(event.date, date);
    }

    // Nếu lặp lại hàng năm
    if (event.repeatType == RepeatType.yearly) {
      // Nếu là event lịch dương
      if (event.type == EventType.solar) {
        return event.date.month == date.month && event.date.day == date.day;
      }

      // Nếu là event lịch âm
      if (event.type == EventType.lunar) {
        // For lunar events, we need to check if the current date has the same lunar date
        // as the original event date when it was created
        final eventLunar = LunarCalendarService.convertToLunar(event.date);
        final dateLunar = LunarCalendarService.convertToLunar(date);

        // Check if both dates have the same lunar month and day
        return eventLunar.month == dateLunar.month &&
            eventLunar.day == dateLunar.day;
      }
    }

    return false;
  }

  // Lấy events trong khoảng thời gian
  static Future<List<Event>> getEventsInRange(
      DateTime start, DateTime end) async {
    final allEvents = await getEvents();
    final eventsInRange = <Event>[];

    DateTime currentDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!currentDate.isAfter(endDate)) {
      for (final event in allEvents) {
        if (_shouldShowEventOnDate(event, currentDate)) {
          // Check if we already have this event in the range
          bool alreadyExists = false;

          if (event.repeatType == RepeatType.yearly) {
            // For yearly events (both solar and lunar), check if we already have this event (by ID) in the range
            alreadyExists = eventsInRange.any((e) => e.id == event.id);
          } else {
            // For non-yearly events, check if we already have this event on this specific date
            alreadyExists = eventsInRange
                .any((e) => e.id == event.id && isSameDay(e.date, currentDate));
          }

          if (!alreadyExists) {
            // Tạo một bản sao của event với ngày hiện tại để hiển thị
            eventsInRange.add(event.copyWith(date: currentDate));
          }
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Sort events by date before returning
    eventsInRange.sort((a, b) => a.date.compareTo(b.date));
    return eventsInRange;
  }
}

// Helper function để so sánh ngày
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
