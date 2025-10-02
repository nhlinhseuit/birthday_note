part of 'lunar_calendar_bloc.dart';

abstract class LunarCalendarState extends Equatable {
  const LunarCalendarState();

  @override
  List<Object?> get props => [];
}

class LunarCalendarInitial extends LunarCalendarState {}

class LunarDateConverted extends LunarCalendarState {
  final LunarDate lunarDate;

  const LunarDateConverted(this.lunarDate);

  @override
  List<Object> get props => [lunarDate];
}

class LunarHolidayLoaded extends LunarCalendarState {
  final String? holiday;

  const LunarHolidayLoaded(this.holiday);

  @override
  List<Object?> get props => [holiday];
}

class LunarCalendarError extends LunarCalendarState {
  final String message;

  const LunarCalendarError(this.message);

  @override
  List<Object> get props => [message];
}

