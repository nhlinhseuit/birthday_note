import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:flutter/cupertino.dart';

class EditPersonScreen extends StatefulWidget {
  final Event event;

  const EditPersonScreen({
    super.key,
    required this.event,
  });

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _personNotesController = TextEditingController();

  late RelationshipType _selectedRelationship;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _personNameController.text = widget.event.personName ?? '';
    _personNotesController.text = widget.event.personNotes ?? '';
    _selectedRelationship =
        widget.event.relationship ?? RelationshipType.friends;
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _personNotesController.dispose();
    super.dispose();
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

  Future<void> _saveChanges() async {
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate new title with updated person name
      String finalTitle = widget.event.title;
      if (widget.event.personName != null &&
          widget.event.personName!.isNotEmpty) {
        // Replace the old person name in title with new one
        final oldPersonName = widget.event.personName!;
        final newPersonName = _personNameController.text.trim();
        finalTitle = finalTitle.replaceAll(oldPersonName, newPersonName);
      } else {
        // If no person name before, append new name to title
        finalTitle =
            '${widget.event.title} ${_personNameController.text.trim()}';
      }

      final updatedEvent = widget.event.copyWith(
        title: finalTitle,
        personName: _personNameController.text.trim(),
        relationship: _selectedRelationship,
        personNotes: _personNotesController.text.trim().isEmpty
            ? null
            : _personNotesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await EventService.updateEvent(updatedEvent);

      if (mounted) {
        Navigator.pop(context, updatedEvent);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Thành công'),
            content: const Text('Đã cập nhật thông tin thành công!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: const Text('Có lỗi xảy ra khi cập nhật thông tin'),
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.black,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveChanges,
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
                  // Person Name
                  const Text(
                    'Tên người',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _personNameController,
                    placeholder: 'Nhập tên người...',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Relationship
                  const Text(
                    'Mối quan hệ',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showRelationshipPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CupertinoColors.systemGrey4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getRelationshipText(_selectedRelationship),
                              style: const TextStyle(
                                color: CupertinoColors.black,
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

                  const SizedBox(height: 20),

                  // Person Notes
                  const Text(
                    'Ghi chú',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _personNotesController,
                    placeholder: 'Nhập ghi chú về người này...',
                    maxLines: 5,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : _saveChanges,
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
                          : const Text(
                              'Lưu thay đổi',
                              style: TextStyle(
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
}
