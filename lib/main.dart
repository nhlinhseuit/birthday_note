import 'package:birthday_note/app_view.dart';
import 'package:birthday_note/core/di/injection.dart';
import 'package:birthday_note/features/events/presentation/bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<EventBloc>()..add(LoadAllEventsEvent()),
        ),
      ],
      child: const MyAppView(),
    );
  }
}
