import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:birthday_note/features/lunar_calendar/domain/entities/lunar_date.dart';
import 'package:birthday_note/features/lunar_calendar/domain/usecases/convert_to_lunar.dart';
import 'package:birthday_note/features/lunar_calendar/domain/usecases/get_lunar_holiday.dart';

part 'lunar_calendar_event.dart';
part 'lunar_calendar_state.dart';

@injectable
class LunarCalendarBloc
    extends Bloc<LunarCalendarEvent, LunarCalendarState> {
  final ConvertToLunar convertToLunar;
  final GetLunarHoliday getLunarHoliday;

  LunarCalendarBloc({
    required this.convertToLunar,
    required this.getLunarHoliday,
  }) : super(LunarCalendarInitial()) {
    on<ConvertSolarToLunarEvent>(_onConvertSolarToLunar);
    on<GetHolidayForDateEvent>(_onGetHolidayForDate);
  }

  Future<void> _onConvertSolarToLunar(
    ConvertSolarToLunarEvent event,
    Emitter<LunarCalendarState> emit,
  ) async {
    final result = await convertToLunar(
      ConvertToLunarParams(event.solarDate),
    );
    result.fold(
      (failure) => emit(LunarCalendarError(failure.message)),
      (lunarDate) => emit(LunarDateConverted(lunarDate)),
    );
  }

  Future<void> _onGetHolidayForDate(
    GetHolidayForDateEvent event,
    Emitter<LunarCalendarState> emit,
  ) async {
    final result = await getLunarHoliday(
      GetLunarHolidayParams(event.solarDate),
    );
    result.fold(
      (failure) => emit(LunarCalendarError(failure.message)),
      (holiday) => emit(LunarHolidayLoaded(holiday)),
    );
  }
}

