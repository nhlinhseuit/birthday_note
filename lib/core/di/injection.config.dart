// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/events/data/datasources/event_local_data_source.dart'
    as _i231;
import '../../features/events/data/repositories/event_repository_impl.dart'
    as _i967;
import '../../features/events/domain/repositories/event_repository.dart'
    as _i199;
import '../../features/events/domain/usecases/add_event.dart' as _i965;
import '../../features/events/domain/usecases/delete_event.dart' as _i474;
import '../../features/events/domain/usecases/get_all_events.dart' as _i443;
import '../../features/events/domain/usecases/get_events_in_range.dart'
    as _i554;
import '../../features/events/domain/usecases/update_event.dart' as _i1051;
import '../../features/events/presentation/bloc/event_bloc.dart' as _i707;
import '../../features/lunar_calendar/data/repositories/lunar_calendar_repository_impl.dart'
    as _i688;
import '../../features/lunar_calendar/domain/repositories/lunar_calendar_repository.dart'
    as _i293;
import '../../features/lunar_calendar/domain/usecases/convert_to_lunar.dart'
    as _i231;
import '../../features/lunar_calendar/domain/usecases/get_lunar_holiday.dart'
    as _i46;
import '../../features/lunar_calendar/presentation/bloc/lunar_calendar_bloc.dart'
    as _i91;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i293.LunarCalendarRepository>(
        () => _i688.LunarCalendarRepositoryImpl());
    gh.lazySingleton<_i231.EventLocalDataSource>(
        () => _i231.EventLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i231.ConvertToLunar>(
        () => _i231.ConvertToLunar(gh<_i293.LunarCalendarRepository>()));
    gh.lazySingleton<_i46.GetLunarHoliday>(
        () => _i46.GetLunarHoliday(gh<_i293.LunarCalendarRepository>()));
    gh.factory<_i91.LunarCalendarBloc>(() => _i91.LunarCalendarBloc(
          convertToLunar: gh<_i231.ConvertToLunar>(),
          getLunarHoliday: gh<_i46.GetLunarHoliday>(),
        ));
    gh.lazySingleton<_i199.EventRepository>(
        () => _i967.EventRepositoryImpl(gh<_i231.EventLocalDataSource>()));
    gh.lazySingleton<_i443.GetAllEvents>(
        () => _i443.GetAllEvents(gh<_i199.EventRepository>()));
    gh.lazySingleton<_i965.AddEvent>(
        () => _i965.AddEvent(gh<_i199.EventRepository>()));
    gh.lazySingleton<_i1051.UpdateEvent>(
        () => _i1051.UpdateEvent(gh<_i199.EventRepository>()));
    gh.lazySingleton<_i474.DeleteEvent>(
        () => _i474.DeleteEvent(gh<_i199.EventRepository>()));
    gh.lazySingleton<_i554.GetEventsInRange>(
        () => _i554.GetEventsInRange(gh<_i199.EventRepository>()));
    gh.factory<_i707.EventBloc>(() => _i707.EventBloc(
          getAllEvents: gh<_i443.GetAllEvents>(),
          getEventsInRange: gh<_i554.GetEventsInRange>(),
          addEvent: gh<_i965.AddEvent>(),
          updateEvent: gh<_i1051.UpdateEvent>(),
          deleteEvent: gh<_i474.DeleteEvent>(),
        ));
    return this;
  }
}
