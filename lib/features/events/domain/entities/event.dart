import 'package:equatable/equatable.dart';

enum EventType { solar, lunar }

enum RepeatType { none, yearly }

class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final EventType type;
  final RepeatType repeatType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
    required this.repeatType,
    required this.createdAt,
    this.updatedAt,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
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
      date: date ?? this.date,
      type: type ?? this.type,
      repeatType: repeatType ?? this.repeatType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        type,
        repeatType,
        createdAt,
        updatedAt,
      ];
}

