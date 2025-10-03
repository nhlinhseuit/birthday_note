import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/event_detail_screen.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';

class SwipeableEventItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onEventDeleted;
  final VoidCallback? onEventUpdated;

  const SwipeableEventItem({
    super.key,
    required this.event,
    this.onEventDeleted,
    this.onEventUpdated,
  });

  Color _getEventColor(Event event) {
    if (event.type == EventType.lunar) {
      return CupertinoColors.systemPurple;
    }
    return CupertinoColors.systemBlue;
  }

  IconData _getEventIcon(Event event) {
    if (event.type == EventType.lunar) {
      return CupertinoIcons.calendar;
    }
    return CupertinoIcons.calendar_today;
  }

  String _getCountdownText(Event event) {
    // Always calculate countdown based on solar date (event.date)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate =
        DateTime(event.date.year, event.date.month, event.date.day);

    final difference = eventDate.difference(today).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference == -1) {
      return 'Hôm qua';
    } else if (difference > 0) {
      return '$difference ngày';
    } else {
      return '${-difference} ngày trước';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart, // Swipe left to delete
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.delete,
              color: CupertinoColors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              'Xóa',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Xóa sự kiện'),
            content:
                Text('Bạn có chắc chắn muốn xóa sự kiện "${event.title}"?'),
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
      },
      onDismissed: (direction) async {
        try {
          await EventService.deleteEvent(event.id);
          onEventDeleted?.call();
        } catch (e) {
          // Show error dialog if deletion fails
          if (context.mounted) {
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
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.all(16),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );

            // Refresh events if event was deleted
            if (result == true) {
              onEventDeleted?.call();
            }
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
                    if (event.type == EventType.lunar) ...[
                      // For lunar events, show lunar date prominently
                      Text(
                        LunarCalendarService.getLunarInfo(event.date),
                        style: const TextStyle(
                          color: CupertinoColors.systemPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Show solar date below lunar date
                      Text(
                        'Dương lịch: ${AppUtils.formatDateToVietnamese(event.date)}',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      // For solar events, show solar date normally
                      Text(
                        AppUtils.formatDateToVietnamese(event.date),
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        event.description!,
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCountdownText(event),
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
