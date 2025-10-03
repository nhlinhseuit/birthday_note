import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:birthday_note/services/lunar_calendar_service.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../features/events/domain/entities/test_event.dart';

class CreateEventScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final Event? editingEvent;

  const CreateEventScreen({
    super.key,
    this.selectedDate,
    this.editingEvent,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

List<TestEvent>? testEvents;

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _personNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  EventType _selectedType = EventType.solar;
  RepeatType _selectedRepeat = RepeatType.yearly;
  RelationshipType? _selectedRelationship;
  bool _isLoading = false;

  // Store the currently displayed date for the date picker
  DateTime get _displayedDate {
    if (_selectedType == EventType.solar) {
      return _selectedDate;
    } else {
      // For lunar calendar, we need to find a solar date that corresponds to the current lunar display
      return _findSolarDateForCurrentLunar();
    }
  }

  @override
  void initState() {
    super.initState();

    testEvents = List.generate(10, (index) => TestEvent());

    if (widget.editingEvent != null) {
      // Editing mode - populate fields with existing event data
      final event = widget.editingEvent!;
      _titleController.text = event.title;
      _personNameController.text = event.personName ?? '';
      _descriptionController.text = event.description ?? '';
      _selectedDate = event.date;
      _selectedType = event.type;
      _selectedRepeat = event.repeatType;
      _selectedRelationship = event.relationship;
    } else if (widget.selectedDate != null) {
      // Creating new event with pre-selected date
      _selectedDate = widget.selectedDate!;
    }
  }

  @override
  void dispose() {
    // testEvents?.forEach((element) => element.dispose());
    // testEvents = null;
    _titleController.dispose();
    _personNameController.dispose();
    // _titleController2.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    // Use the currently displayed date as the initial value for the picker
    DateTime tempDate = _displayedDate;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
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
                        setState(() {
                          _selectedDate = tempDate;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _displayedDate,
                  minimumYear: 2020,
                  maximumYear: 2030,
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

  DateTime _findSolarDateForCurrentLunar() {
    // Get the current lunar date info
    final currentLunarInfo = LunarCalendarService.getLunarInfo(_selectedDate);

    // Parse the lunar info to extract day and month
    // Format: "8 Tháng 12 năm 2024"
    final parts = currentLunarInfo.split(' ');
    if (parts.length >= 4) {
      final lunarDay = int.tryParse(parts[0]) ?? 1;
      final lunarMonth = int.tryParse(parts[2]) ?? 1;

      // Search in a range of years to find a matching solar date
      final currentYear = DateTime.now().year;

      // Search from 2 years ago to 2 years in the future
      for (int year = currentYear - 2; year <= currentYear + 2; year++) {
        // Search each day in the year
        for (int day = 1; day <= 365; day++) {
          final testDate = DateTime(year, 1, 1).add(Duration(days: day - 1));
          final testLunarInfo = LunarCalendarService.getLunarInfo(testDate);

          // Parse test lunar info
          final testParts = testLunarInfo.split(' ');
          if (testParts.length >= 4) {
            final testLunarDay = int.tryParse(testParts[0]) ?? 0;
            final testLunarMonth = int.tryParse(testParts[2]) ?? 0;

            if (testLunarDay == lunarDay && testLunarMonth == lunarMonth) {
              return testDate;
            }
          }
        }
      }
    }

    // If no match found, return the original date
    return _selectedDate;
  }

  void _showRelationshipPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 50,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _selectedRelationship = RelationshipType.values[index];
                  });
                },
                children: RelationshipType.values.map((relationship) {
                  return Center(
                    child: Text(_getRelationshipText(relationship)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Thiếu thông tin'),
          content: const Text('Vui lòng nhập tiêu đề sự kiện'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Validate person name
    if (_personNameController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Thiếu thông tin'),
          content: const Text('Vui lòng nhập tên người'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Validate relationship
    if (_selectedRelationship == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Thiếu thông tin'),
          content: const Text('Vui lòng chọn mối quan hệ'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Generate combined title
    String finalTitle =
        '${_titleController.text.trim()} ${_personNameController.text.trim()}';

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.editingEvent != null) {
        // Update existing event
        final updatedEvent = Event(
          id: widget.editingEvent!.id,
          title: finalTitle,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          personName: _personNameController.text.trim(),
          relationship: _selectedRelationship,
          personNotes: null, // Notes can be added later in person detail
          date: _selectedDate,
          type: _selectedType,
          repeatType: _selectedRepeat,
          createdAt: widget.editingEvent!.createdAt,
        );

        await EventService.updateEvent(updatedEvent);

        if (mounted) {
          Navigator.pop(context, updatedEvent);
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Thành công'),
              content: const Text('Đã cập nhật sự kiện thành công!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } else {
        // Create new event
        final event = Event(
          id: const Uuid().v4(),
          title: finalTitle,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          personName: _personNameController.text.trim(),
          relationship: _selectedRelationship,
          personNotes: null, // Notes can be added later in person detail
          date: _selectedDate,
          type: _selectedType,
          repeatType: _selectedRepeat,
          createdAt: DateTime.now(),
        );

        await EventService.addEvent(event);

        if (mounted) {
          Navigator.pop(context, event);
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Thành công'),
              content: const Text('Đã tạo sự kiện thành công!'),
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
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: const Text('Có lỗi xảy ra khi tạo sự kiện'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final holiday = LunarCalendarService.getLunarHoliday(_selectedDate);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text(
          widget.editingEvent != null ? 'Sửa sự kiện' : 'Tạo sự kiện',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.black,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveEvent,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text(
                  'Lưu',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside input fields
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loại lịch (moved to top)
                  const Text(
                    'Loại lịch',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          EventType.solar,
                          'Lịch Dương',
                          Icons.calendar_today,
                          'Sự kiện theo ngày dương lịch',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeOption(
                          EventType.lunar,
                          'Lịch Âm',
                          Icons.calendar_month,
                          'Sự kiện theo ngày âm lịch',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Thông tin ngày được chọn
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
                        const Text(
                          'Ngày sự kiện',
                          style: TextStyle(
                            color: CupertinoColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: CupertinoColors.systemGrey4),
                            ),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.calendar,
                                    color: CupertinoColors.black, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedType == EventType.solar
                                            ? AppUtils.formatDateToVietnamese(
                                                _selectedDate)
                                            : LunarCalendarService.getLunarInfo(
                                                _selectedDate),
                                        style: const TextStyle(
                                          color: CupertinoColors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedType == EventType.solar
                                            ? 'Dương lịch'
                                            : 'Âm lịch',
                                        style: const TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(CupertinoIcons.chevron_down,
                                    color: CupertinoColors.systemGrey,
                                    size: 16),
                              ],
                            ),
                          ),
                        ),
                        if (holiday != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  CupertinoColors.systemOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: CupertinoColors.systemOrange
                                      .withOpacity(0.3)),
                            ),
                            child: Text(
                              holiday,
                              style: const TextStyle(
                                color: CupertinoColors.systemOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tiêu đề sự kiện
                  const Text(
                    'Tiêu đề',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'Nhập tiêu đề sự kiện...',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Thông tin người
                  const Text(
                    'Thông tin người *',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _personNameController,
                          placeholder: 'Tên người *',
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: CupertinoColors.systemGrey4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showRelationshipPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: CupertinoColors.systemGrey4),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedRelationship == null
                                        ? 'Mối quan hệ *'
                                        : _getRelationshipText(
                                            _selectedRelationship!),
                                    style: TextStyle(
                                      color: _selectedRelationship == null
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: CupertinoColors.systemGrey,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Mô tả
                  const Text(
                    'Mô tả (tùy chọn)',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _descriptionController,
                    placeholder: 'Nhập mô tả sự kiện...',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lặp lại
                  const Text(
                    'Lặp lại',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRepeatOption(
                          RepeatType.yearly,
                          'Hàng năm',
                          Icons.repeat,
                          'Lặp lại mỗi năm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRepeatOption(
                          RepeatType.none,
                          'Không lặp',
                          Icons.event,
                          'Chỉ hiển thị một lần',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Nút lưu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : _saveEvent,
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Đang lưu...',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.editingEvent != null
                                  ? 'Cập nhật'
                                  : 'Tạo sự kiện',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(
      EventType type, String title, IconData icon, String subtitle) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.1)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.label,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption(
      RepeatType type, String title, IconData icon, String subtitle) {
    final isSelected = _selectedRepeat == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRepeat = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.1)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.label,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
