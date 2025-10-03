import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/edit_person_screen.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';

class PersonDetailScreen extends StatefulWidget {
  final Event event;

  const PersonDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Event _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  String _getRelationshipText(RelationshipType relationship) {
    switch (relationship) {
      case RelationshipType.family:
        return 'Gia đình';
      case RelationshipType.friends:
        return 'Bạn bè';
      case RelationshipType.oldFriends:
        return 'Bạn cũ';
    }
  }

  Color _getRelationshipColor(RelationshipType relationship) {
    switch (relationship) {
      case RelationshipType.family:
        return CupertinoColors.systemRed;
      case RelationshipType.friends:
        return CupertinoColors.systemBlue;
      case RelationshipType.oldFriends:
        return CupertinoColors.systemPurple;
    }
  }

  IconData _getRelationshipIcon(RelationshipType relationship) {
    switch (relationship) {
      case RelationshipType.family:
        return CupertinoIcons.heart_fill;
      case RelationshipType.friends:
        return CupertinoIcons.person_2_fill;
      case RelationshipType.oldFriends:
        return CupertinoIcons.clock_fill;
    }
  }

  Future<void> _editPerson() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditPersonScreen(event: _currentEvent),
      ),
    );

    if (result != null && result is Event) {
      setState(() {
        _currentEvent = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final relationshipColor =
        _getRelationshipColor(_currentEvent.relationship!);
    final relationshipIcon = _getRelationshipIcon(_currentEvent.relationship!);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text(
          _currentEvent.personName!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _editPerson,
          child: const Text(
            'Sửa',
            style: TextStyle(
              color: CupertinoColors.systemBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Person Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar and Name
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: relationshipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: relationshipColor.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        relationshipIcon,
                        color: relationshipColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentEvent.personName!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentEvent.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Relationship Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: relationshipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: relationshipColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getRelationshipText(_currentEvent.relationship!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: relationshipColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Event Details
              const Text(
                'Thông tin sự kiện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 20,
                          color: relationshipColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ngày sự kiện',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: relationshipColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentEvent.type == EventType.solar
                          ? AppUtils.formatDateToVietnamese(_currentEvent.date)
                          : LunarCalendarService.getLunarInfo(
                              _currentEvent.date),
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentEvent.type == EventType.solar
                          ? 'Dương lịch'
                          : 'Âm lịch',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),

              if (_currentEvent.description != null &&
                  _currentEvent.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.text_quote,
                            size: 20,
                            color: relationshipColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mô tả',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: relationshipColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentEvent.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Person Notes
              const Text(
                'Ghi chú về người này',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 20,
                          color: relationshipColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: relationshipColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentEvent.personNotes?.isNotEmpty == true
                          ? _currentEvent.personNotes!
                          : 'Chưa có ghi chú nào...',
                      style: TextStyle(
                        fontSize: 16,
                        color: _currentEvent.personNotes?.isNotEmpty == true
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey,
                        fontStyle: _currentEvent.personNotes?.isNotEmpty == true
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Repeat Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.repeat,
                      size: 20,
                      color: relationshipColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lặp lại: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: relationshipColor,
                      ),
                    ),
                    Text(
                      _currentEvent.repeatType == RepeatType.yearly
                          ? 'Hàng năm'
                          : 'Một lần',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
