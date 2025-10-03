import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/create_event_screen.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xóa sự kiện'),
        content: Text('Bạn có chắc chắn muốn xóa sự kiện "${_event.title}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Xóa'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await EventService.deleteEvent(_event.id);
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Lỗi'),
              content: const Text('Không thể xóa sự kiện. Vui lòng thử lại.'),
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
  }

  Future<void> _editEvent() async {
    final updatedEvent = await Navigator.push<Event>(
      context,
      CupertinoPageRoute(
        builder: (context) => CreateEventScreen(editingEvent: _event),
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        _event = updatedEvent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text(
          'Chi tiết sự kiện',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _editEvent,
          child: const Text(
            'Sửa',
            style: TextStyle(
              color: CupertinoColors.systemBlue,
              fontSize: 16,
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
              // Event Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    if (_event.description != null &&
                        _event.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _event.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Event Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin sự kiện',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calendar Type
                    _buildInfoRow(
                      icon: CupertinoIcons.calendar,
                      label: 'Loại lịch',
                      value: _event.type == EventType.lunar
                          ? 'Âm lịch'
                          : 'Dương lịch',
                      valueColor: _event.type == EventType.lunar
                          ? CupertinoColors.systemPurple
                          : CupertinoColors.systemBlue,
                    ),

                    const SizedBox(height: 12),

                    // Date Information
                    if (_event.type == EventType.lunar) ...[
                      _buildInfoRow(
                        icon: CupertinoIcons.calendar,
                        label: 'Ngày âm lịch',
                        value: LunarCalendarService.getLunarInfo(_event.date),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: CupertinoIcons.calendar_today,
                        label: 'Ngày dương lịch',
                        value: AppUtils.formatDateToVietnamese(_event.date),
                      ),
                    ] else ...[
                      _buildInfoRow(
                        icon: CupertinoIcons.calendar_today,
                        label: 'Ngày sự kiện',
                        value: AppUtils.formatDateToVietnamese(_event.date),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Repeat Type
                    _buildInfoRow(
                      icon: CupertinoIcons.repeat,
                      label: 'Lặp lại',
                      value: _event.repeatType == RepeatType.yearly
                          ? 'Hàng năm'
                          : 'Một lần',
                    ),

                    const SizedBox(height: 12),

                    // Created Date
                    _buildInfoRow(
                      icon: CupertinoIcons.time,
                      label: 'Ngày tạo',
                      value: AppUtils.formatDateToVietnamese(_event.createdAt),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Simple iOS native delete button
              CupertinoButton(
                onPressed: _deleteEvent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Xóa sự kiện',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? CupertinoColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
