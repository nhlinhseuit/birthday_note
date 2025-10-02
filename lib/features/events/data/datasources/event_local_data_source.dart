import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_note/features/events/data/models/event_model.dart';

abstract class EventLocalDataSource {
  Future<List<EventModel>> getAllEvents();
  Future<void> cacheEvent(EventModel event);
  Future<void> updateCachedEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<void> cacheEvents(List<EventModel> events);
}

const String CACHED_EVENTS = 'CACHED_EVENTS';

@LazySingleton(as: EventLocalDataSource)
class EventLocalDataSourceImpl implements EventLocalDataSource {
  final SharedPreferences sharedPreferences;

  EventLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<EventModel>> getAllEvents() async {
    final jsonString = sharedPreferences.getString(CACHED_EVENTS);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => EventModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> cacheEvent(EventModel event) async {
    final events = await getAllEvents();
    events.add(event);
    await cacheEvents(events);
  }

  @override
  Future<void> updateCachedEvent(EventModel event) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await cacheEvents(events);
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    final events = await getAllEvents();
    events.removeWhere((e) => e.id == id);
    await cacheEvents(events);
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    final jsonList = events.map((e) => e.toJson()).toList();
    await sharedPreferences.setString(CACHED_EVENTS, json.encode(jsonList));
  }
}
