import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Initialize injectable
  getIt.init();
}

