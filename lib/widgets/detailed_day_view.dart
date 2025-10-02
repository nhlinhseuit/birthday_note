import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:flutter/cupertino.dart';

class DetailedDayView extends StatelessWidget {
  final DateTime selectedDate;
  final bool showSolarCalendar;
  final bool showLunarCalendar;

  const DetailedDayView({
    super.key,
    required this.selectedDate,
    this.showSolarCalendar = true,
    this.showLunarCalendar = true,
  });

  @override
  Widget build(BuildContext context) {
    final lunarInfo = LunarCalendarService.convertToLunar(selectedDate);
    final holiday = LunarCalendarService.getLunarHoliday(selectedDate);

    final months = [
      '',
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
      'Tháng 12'
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: showSolarCalendar && showLunarCalendar
          ? _buildTwoColumnView(selectedDate, lunarInfo, holiday, months)
          : _buildSingleColumnView(lunarInfo, holiday),
    );
  }

  Widget _buildTwoColumnView(DateTime selectedDate, dynamic lunarInfo,
      String? holiday, List<String> months) {
    return Row(
      children: [
        // Solar Calendar Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Dương Lịch',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${selectedDate.day}',
                style: const TextStyle(
                  color: CupertinoColors.systemGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${months[selectedDate.month]} năm ${selectedDate.year}',
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Vertical divider
        Container(
          width: 1,
          height: 60,
          color: CupertinoColors.systemGrey4,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        // Lunar Calendar Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Âm lịch',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${lunarInfo.day}',
                style: const TextStyle(
                  color: CupertinoColors.systemGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tháng ${lunarInfo.month} năm ${lunarInfo.year}${lunarInfo.isLeapMonth ? " nhuận" : ""}',
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              if (holiday != null) ...[
                const SizedBox(height: 4),
                Text(
                  holiday,
                  style: const TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnView(dynamic lunarInfo, String? holiday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Âm lịch',
          style: TextStyle(
            color: CupertinoColors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${lunarInfo.day}',
          style: const TextStyle(
            color: CupertinoColors.systemGreen,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tháng ${lunarInfo.month} năm ${lunarInfo.year}${lunarInfo.isLeapMonth ? " nhuận" : ""}',
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 12,
          ),
        ),
        if (holiday != null) ...[
          const SizedBox(height: 4),
          Text(
            holiday,
            style: const TextStyle(
              color: CupertinoColors.systemRed,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
