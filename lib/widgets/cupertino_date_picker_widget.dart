import 'package:flutter/cupertino.dart';

class CupertinoDatePickerWidget {
  /// Show a Cupertino-style date picker for solar/Gregorian dates
  static Future<void> showSolarDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime) onDateSelected,
    int minimumYear = 2020,
    int maximumYear = 2100,
  }) async {
    DateTime tempDate = initialDate;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey4.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Hủy'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Xong'),
                      onPressed: () {
                        onDateSelected(tempDate);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumYear: minimumYear,
                  maximumYear: maximumYear,
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show a Cupertino-style picker for lunar calendar dates
  static Future<void> showLunarDatePicker({
    required BuildContext context,
    required int initialDay,
    required int initialMonth,
    required int initialYear,
    required Function(int day, int month, int year) onDateSelected,
    int minimumYear = 2020,
    int maximumYear = 2100,
  }) async {
    int selectedDay = initialDay;
    int selectedMonth = initialMonth;
    int selectedYear = initialYear;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey4.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Hủy'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Xong'),
                      onPressed: () {
                        onDateSelected(
                            selectedDay, selectedMonth, selectedYear);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Day picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedDay - 1,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          selectedDay = index + 1;
                        },
                        children: List<Widget>.generate(30, (int index) {
                          return Center(
                            child: Text('Ngày ${index + 1}'),
                          );
                        }),
                      ),
                    ),
                    // Month picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth - 1,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          selectedMonth = index + 1;
                        },
                        children: List<Widget>.generate(12, (int index) {
                          return Center(
                            child: Text('Tháng ${index + 1}'),
                          );
                        }),
                      ),
                    ),
                    // Year picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedYear - minimumYear,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          selectedYear = minimumYear + index;
                        },
                        children: List<Widget>.generate(
                          maximumYear - minimumYear + 1,
                          (int index) {
                            return Center(
                              child: Text('${minimumYear + index}'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
