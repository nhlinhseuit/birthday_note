part of 'lunar_calendar_bloc.dart';

abstract class LunarCalendarEvent extends Equatable {
  const LunarCalendarEvent();

  @override
  List<Object> get props => [];
}

class ConvertSolarToLunarEvent extends LunarCalendarEvent {
  final DateTime solarDate;

  const ConvertSolarToLunarEvent(this.solarDate);

  @override
  List<Object> get props => [solarDate];
}

class GetHolidayForDateEvent extends LunarCalendarEvent {
  final DateTime solarDate;

  const GetHolidayForDateEvent(this.solarDate);

  @override
  List<Object> get props => [solarDate];
}

