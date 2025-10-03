import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/services/event_service.dart';

class DataImportService {
  static Future<void> importBirthdayData() async {
    final currentYear = DateTime.now().year;

    // List of birthday data to import
    final birthdays = [
      // Lunar dates (âm lịch)
      {
        'name': 'Mẹ',
        'date': '29/4',
        'isLunar': true,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Ba',
        'date': '16/6',
        'isLunar': true,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Chị 2',
        'date': '3/3',
        'isLunar': true,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Bản thân',
        'date': '26/9',
        'isLunar': true,
        'relationship': 'Gia đình'
      },

      // Solar dates (default)
      {
        'name': 'Ken',
        'date': '05/10',
        'isLunar': false,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Ben',
        'date': '26/9',
        'isLunar': false,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Khang',
        'date': '12/10',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Minh',
        'date': '26/10',
        'isLunar': false,
        'relationship': 'Bạn cũ'
      },
      {
        'name': 'Tuấn Anh',
        'date': '2/11',
        'isLunar': false,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Như',
        'date': '7/1',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Thái',
        'date': '25/1',
        'isLunar': false,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Tuấn Anh',
        'date': '11/2',
        'isLunar': false,
        'relationship': 'Gia đình'
      },
      {
        'name': 'Lan Anh',
        'date': '18/3',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Thương',
        'date': '7/5',
        'isLunar': false,
        'relationship': 'Bạn cũ'
      },
      {
        'name': 'Lộc',
        'date': '24/6',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Vĩ',
        'date': '19/7',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Nhật Khánh',
        'date': '29/7',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Tâm',
        'date': '6/8',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Hữu',
        'date': '10/9',
        'isLunar': false,
        'relationship': 'Bạn bè'
      },
      {
        'name': 'Gia Huy',
        'date': '15/9',
        'isLunar': false,
        'relationship': 'Bạn cũ'
      },
    ];

    print('Starting birthday import...');

    for (final birthday in birthdays) {
      try {
        final name = birthday['name'] as String;
        final dateStr = birthday['date'] as String;
        final isLunar = birthday['isLunar'] as bool;
        final relationshipStr = birthday['relationship'] as String;

        // Parse date
        final parts = dateStr.split('/');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        // Convert relationship string to enum
        RelationshipType relationship;
        switch (relationshipStr) {
          case 'Gia đình':
            relationship = RelationshipType.family;
            break;
          case 'Bạn bè':
            relationship = RelationshipType.friends;
            break;
          case 'Bạn cũ':
            relationship = RelationshipType.oldFriends;
            break;
          default:
            relationship = RelationshipType.friends;
        }

        DateTime eventDate;
        EventType eventType;

        if (isLunar) {
          // For lunar dates, we'll use the lunar date as provided
          // The lunar calendar service will handle the conversion when needed
          eventDate = DateTime(currentYear, month, day);
          eventType = EventType.lunar;
        } else {
          // For solar dates, use directly
          eventDate = DateTime(currentYear, month, day);
          eventType = EventType.solar;
        }

        // Create event
        final event = Event(
          id: '${name.toLowerCase().replaceAll(' ', '_')}_${currentYear}',
          title: 'Sinh nhật $name',
          date: eventDate,
          type: eventType,
          repeatType: RepeatType.yearly,
          personName: name,
          relationship: relationship,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Check if event already exists
        final existingEvents = await EventService.getEvents();
        final exists = existingEvents
            .any((e) => e.personName == name && e.title == 'Sinh nhật $name');

        if (!exists) {
          // Add event
          await EventService.addEvent(event);
          print(
              '✅ Added: ${event.title} (${eventType == EventType.lunar ? 'Âm lịch' : 'Dương lịch'}) - $relationshipStr');
        } else {
          print('⏭️ Skipped: ${event.title} (already exists)');
        }
      } catch (e) {
        print('❌ Error adding ${birthday['name']}: $e');
      }
    }

    print('Birthday import completed!');
  }
}
