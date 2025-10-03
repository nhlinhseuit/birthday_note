import 'package:birthday_note/lunar_calendar_screen.dart';
import 'package:birthday_note/main_screen.dart';
import 'package:birthday_note/screens/upcoming_events_screen.dart';
import 'package:birthday_note/screens/people_screen.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';

class HomeScreenExpense extends StatefulWidget {
  const HomeScreenExpense({super.key});

  @override
  State<HomeScreenExpense> createState() => _HomeScreenExpenseState();
}

class _HomeScreenExpenseState extends State<HomeScreenExpense> {
  int index = 0;

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return const MainScreen();
      case 1:
        return const LunarCalendarScreen();
      case 2:
        return const UpcomingEventsScreen();
      case 3:
        return const PeopleScreen();
      default:
        return const MainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await AppUtils.onWillPop(context);
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: CupertinoPageScaffold(
        // navigationBar: CupertinoNavigationBar(
        //   backgroundColor: CupertinoColors.white,
        //   middle: Text(
        //     index == 0
        //         ? 'Lịch'
        //         : index == 1
        //             ? 'Lịch Âm'
        //             : 'Sắp tới',
        //     style: const TextStyle(
        //       fontSize: 17,
        //       fontWeight: FontWeight.w600,
        //       color: CupertinoColors.black,
        //     ),
        //   ),
        // ),
        child: Column(
          children: [
            Expanded(child: _getBodyForIndex(index)),
            CupertinoTabBar(
              currentIndex: index,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar),
                  label: 'Lịch',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar_badge_plus),
                  label: 'Lịch Âm',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.bell),
                  label: 'Sắp tới',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_3_fill),
                  label: 'Mọi người',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
