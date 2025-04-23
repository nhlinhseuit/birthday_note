import 'package:birthday_note/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value:  SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.grey.shade100,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "My Application",
          home: const HomeScreenExpense(), // ✅ Điều hướng theo trạng thái login
        ));
  }

}
