import 'package:birthday_note/models/event_model.dart';
import 'package:birthday_note/screens/edit_person_screen.dart';
import 'package:birthday_note/screens/person_detail_screen.dart';
import 'package:birthday_note/services/event_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<Event> _allEvents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RelationshipType? _selectedRelationship; // null means no relationship filter

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await EventService.getEvents();
      // Filter events that have person information
      final peopleEvents = events
          .where((event) =>
              event.personName != null &&
              event.personName!.isNotEmpty &&
              event.relationship != null)
          .toList();

      setState(() {
        _allEvents = peopleEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Event> _getFilteredEvents() {
    List<Event> filteredEvents = _allEvents;

    // Apply search filter if search query is not empty
    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents
          .where((event) => event.personName!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply relationship filter if a relationship is selected
    if (_selectedRelationship != null) {
      filteredEvents = filteredEvents
          .where((event) => event.relationship == _selectedRelationship)
          .toList();
    }

    return filteredEvents;
  }

  void _showRelationshipFilterModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _RelationshipFilterModal(
        selectedRelationship: _selectedRelationship,
        onRelationshipSelected: (relationship) {
          setState(() {
            _selectedRelationship = relationship;
          });
        },
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text(
          'Mọi người',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar with filter button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                        ),
                      ),
                      child: CupertinoTextField(
                        controller: _searchController,
                        placeholder: 'Tìm kiếm theo tên...',
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.transparent),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          // Hide keyboard when search is submitted
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: _showRelationshipFilterModal,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedRelationship != null
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedRelationship != null
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemGrey4,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.slider_horizontal_3,
                        color: _selectedRelationship != null
                            ? CupertinoColors.white
                            : CupertinoColors.systemGrey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final filteredEvents = _getFilteredEvents();

    if (_allEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_3_fill,
              size: 80,
              color: CupertinoColors.systemGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thông tin người nào',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo sự kiện với thông tin người để xem ở đây',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      );
    }

    if (filteredEvents.isEmpty) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 80,
                  color: CupertinoColors.systemGrey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Không tìm thấy người nào'
                      : _selectedRelationship != null
                          ? 'Không có người nào với mối quan hệ này'
                          : 'Không có kết quả',
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                if (_searchQuery.isNotEmpty || _selectedRelationship != null)
                  const Text(
                    'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildPersonCard(event);
      },
    );
  }

  Widget _buildPersonCard(Event event) {
    final relationshipColor = _getRelationshipColor(event.relationship!);
    final relationshipIcon = _getRelationshipIcon(event.relationship!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToPersonDetail(event),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.systemGrey4),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildRelationshipIcon(relationshipColor, relationshipIcon),
              const SizedBox(width: 16),
              Expanded(child: _buildPersonInfo(event, relationshipColor)),
              _buildDateAndEditButton(event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipIcon(
      Color relationshipColor, IconData relationshipIcon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: relationshipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: relationshipColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        relationshipIcon,
        color: relationshipColor,
        size: 24,
      ),
    );
  }

  Widget _buildPersonInfo(Event event, Color relationshipColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.personName!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 8),
        _buildRelationshipAndTypeRow(event, relationshipColor),
        if (event.personNotes != null && event.personNotes!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            event.personNotes!,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey2,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildRelationshipAndTypeRow(Event event, Color relationshipColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: relationshipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: relationshipColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            _getRelationshipText(event.relationship!),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: relationshipColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          event.type == EventType.lunar
              ? CupertinoIcons.calendar
              : CupertinoIcons.calendar_today,
          size: 12,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          event.type == EventType.lunar ? 'Âm lịch' : 'Dương lịch',
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndEditButton(Event event) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${event.date.day}/${event.date.month}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            Text(
              '${event.date.year}',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        CupertinoButton(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 4),
          onPressed: () => _navigateToEditPerson(event),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CupertinoColors.systemBlue.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              CupertinoIcons.pencil,
              color: CupertinoColors.systemBlue,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToPersonDetail(Event event) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PersonDetailScreen(event: event),
      ),
    );
    if (result == true) {
      _loadPeople();
    }
  }

  Future<void> _navigateToEditPerson(Event event) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditPersonScreen(event: event),
      ),
    );
    if (result != null) {
      _loadPeople();
    }
  }
}

class _RelationshipFilterModal extends StatefulWidget {
  final RelationshipType? selectedRelationship;
  final Function(RelationshipType?) onRelationshipSelected;

  const _RelationshipFilterModal({
    required this.selectedRelationship,
    required this.onRelationshipSelected,
  });

  @override
  State<_RelationshipFilterModal> createState() =>
      _RelationshipFilterModalState();
}

class _RelationshipFilterModalState extends State<_RelationshipFilterModal> {
  late RelationshipType? _tempSelectedRelationship;

  @override
  void initState() {
    super.initState();
    _tempSelectedRelationship = widget.selectedRelationship;
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text(
          'Lọc theo mối quan hệ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 16,
            ),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            widget.onRelationshipSelected(_tempSelectedRelationship);
            Navigator.pop(context);
          },
          child: const Text(
            'Lọc',
            style: TextStyle(
              color: CupertinoColors.systemBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Clear filter option
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  setState(() {
                    _tempSelectedRelationship = null;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _tempSelectedRelationship == null
                        ? CupertinoColors.systemBlue.withOpacity(0.1)
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _tempSelectedRelationship == null
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.systemGrey4,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.clear_circled,
                        color: _tempSelectedRelationship == null
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tất cả mối quan hệ',
                        style: TextStyle(
                          color: _tempSelectedRelationship == null
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Relationship options
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: RelationshipType.values.length,
                itemBuilder: (context, index) {
                  final relationship = RelationshipType.values[index];
                  final isSelected = _tempSelectedRelationship == relationship;
                  final relationshipColor = _getRelationshipColor(relationship);
                  final relationshipIcon = _getRelationshipIcon(relationship);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _tempSelectedRelationship = relationship;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? relationshipColor.withOpacity(0.1)
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? relationshipColor
                                : CupertinoColors.systemGrey4,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? relationshipColor
                                    : CupertinoColors.systemGrey5,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      CupertinoIcons.checkmark,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              relationshipIcon,
                              color: isSelected
                                  ? relationshipColor
                                  : CupertinoColors.systemGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getRelationshipText(relationship),
                              style: TextStyle(
                                color: isSelected
                                    ? relationshipColor
                                    : CupertinoColors.systemGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
