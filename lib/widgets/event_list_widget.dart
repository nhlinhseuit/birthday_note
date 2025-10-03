import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/event_detail_screen.dart';
import 'package:flutter/cupertino.dart';

class EventListWidget extends StatelessWidget {
  final List<Event> events;
  final bool isLoading;
  final VoidCallback? onEventDeleted;

  const EventListWidget({
    super.key,
    required this.events,
    required this.isLoading,
    this.onEventDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (events.isEmpty) {
      return const Center(
        child: Text(
          'Không có sự kiện nào',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      children: events.map((event) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CupertinoColors.systemGrey4),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: event.type == EventType.lunar
                        ? CupertinoColors.systemPurple
                        : CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.description != null &&
                          event.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description!,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            event.type == EventType.lunar
                                ? CupertinoIcons.calendar
                                : CupertinoIcons.calendar_today,
                            size: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.type == EventType.lunar
                                ? 'Âm lịch'
                                : 'Dương lịch',
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            event.repeatType == RepeatType.yearly
                                ? CupertinoIcons.repeat
                                : CupertinoIcons.circle,
                            size: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.repeatType == RepeatType.yearly
                                ? 'Hàng năm'
                                : 'Một lần',
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
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
