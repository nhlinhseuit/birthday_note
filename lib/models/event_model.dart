import 'package:equatable/equatable.dart';

enum EventType {
  solar, // Lịch dương
  lunar, // Lịch âm
}

enum RepeatType {
  none, // Không lặp lại
  yearly, // Lặp lại hàng năm
}

enum RelationshipType {
  family, // Gia đình
  friends, // Bạn bè
  oldFriends, // Bạn cũ
}

class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? personName;
  final RelationshipType? relationship;
  final String? personNotes;
  final DateTime date;
  final EventType type; // Lịch dương hay lịch âm
  final RepeatType repeatType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.personName,
    this.relationship,
    this.personNotes,
    required this.date,
    required this.type,
    this.repeatType = RepeatType.none,
    required this.createdAt,
    this.updatedAt,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? personName,
    RelationshipType? relationship,
    String? personNotes,
    DateTime? date,
    EventType? type,
    RepeatType? repeatType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      personName: personName ?? this.personName,
      relationship: relationship ?? this.relationship,
      personNotes: personNotes ?? this.personNotes,
      date: date ?? this.date,
      type: type ?? this.type,
      repeatType: repeatType ?? this.repeatType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'personName': personName,
      'relationship': relationship?.name,
      'personNotes': personNotes,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'repeatType': repeatType.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      personName: json['personName'],
      personNotes: json['personNotes'],
      relationship: json['relationship'] != null
          ? RelationshipType.values.firstWhere(
              (e) => e.name == json['relationship'],
              orElse: () => RelationshipType.friends,
            )
          : null,
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.solar,
      ),
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == json['repeatType'],
        orElse: () => RepeatType.none,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        personName,
        relationship,
        personNotes,
        date,
        type,
        repeatType,
        createdAt,
        updatedAt,
      ];
}
