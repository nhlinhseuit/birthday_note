import 'dart:math';

// import 'package:expense_repository/expense_repository.dart';
import 'package:birthday_note/main_screen.dart';
import 'package:birthday_note/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:mood_cat/screens/home_expense/get_expenses_blocs/bloc/get_expenses_bloc.dart';

class HomeScreenExpense extends StatefulWidget {
  const HomeScreenExpense({super.key});

  @override
  State<HomeScreenExpense> createState() => _HomeScreenExpenseState();
}

class _HomeScreenExpenseState extends State<HomeScreenExpense> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    Color getSelectedItem() {
      return Colors.blue;
    }

    Color getUnSelectedItem() {
      return Colors.grey;
    }

    // return BlocBuilder<GetExpensesBloc, GetExpensesState>(
    //   builder: (context, state) {
    //     if (state is GetExpensesSuccess) {
    return WillPopScope(
      onWillPop: () => AppUtils.onWillPop(context),
      child: Scaffold(
        body: index == 0 ? const MainScreen() : const SizedBox(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Đổ bóng nhẹ
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF324553),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0, // Xóa bóng mặc định để tránh xung đột
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    color: index == 0 ? getSelectedItem() : getUnSelectedItem(),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.graph_square,
                    color: index == 1 ? getSelectedItem() : getUnSelectedItem(),
                  ),
                  label: 'Stats',
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // // var newExpense = await Navigator.push(
            // //   context,
            // //   MaterialPageRoute<Expense>(
            // //     builder: (BuildContext context) => MultiBlocProvider(
            // //       providers: [
            // //         BlocProvider(
            // //           create: (context) =>
            // //               CreateCategoryBloc(FirebaseExpenseRepo()),
            // //         ),
            // //         BlocProvider(
            // //           create: (context) =>
            // //               GetCategoriesBloc(FirebaseExpenseRepo())
            // //                 ..add(GetCategories()),
            // //         ),
            // //         BlocProvider(
            // //           create: (context) =>
            // //               CreateExpenseBloc(FirebaseExpenseRepo()),
            // //         ),
            // //       ],
            // //       child: const AddMood(),
            // //     ),
            // //   ),
            // );

            // if (newExpense != null) {
            //   setState(() {
            //     state.expenses.insert(0, newExpense);
            //   });
            // }
          },
          shape: const CircleBorder(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ],
                  transform: const GradientRotation(pi / 4),
                )),
            child: const Icon(CupertinoIcons.add),
          ),
        ),
      ),
    );

    // } else {
    //   return const Scaffold(
    //       body: Center(child: CircularProgressIndicator()));
    // }
    // },
    // );
  }
}
