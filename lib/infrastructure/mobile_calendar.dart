import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:mail_app/infrastructure/util.dart';

final startDay = DateTime(2023, 1, 1);
final endDay = DateTime(2024, 1, 1);

final DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

Future<UnmodifiableListView<Calendar>> retrieveCalendars() async {
  var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
  if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
    permissionsGranted = await deviceCalendarPlugin.requestPermissions();
    if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
      throw Exception("Not granted access to your calendar");
    }
  }

  final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
  final calendars = calendarsResult.data;

  if (calendars == null) {
    throw Exception("Can not get calendars.\n"
        "Emulatorを使用している場合で、カレンダーを使用したことがない場合、取得に失敗します。\n"
        "Emulatorからカレンダーアプリを開いて、ログインしてからコードを実行してください。");
  }

  return calendars;
}

Calendar getDefaultCalender(UnmodifiableListView<Calendar> calendars) {
  return calendars.firstWhere((element) => element.isDefault ?? false);
}

Future<bool> addEventToCalendar(Calendar selectedCalendar, String summary,
    DateTime dtStart, DateTime dtEnd) async {
  tz.initializeTimeZones();
  final Event event = Event(
    selectedCalendar.id,
    title: summary,
    start: tz.TZDateTime.from(dtStart, tz.local),
    end: tz.TZDateTime.from(dtEnd, tz.local),
  );

  final Result<String> createResult =
      (await deviceCalendarPlugin.createOrUpdateEvent(event))!;
  if (createResult.isSuccess && (createResult.data?.isNotEmpty ?? false)) {
    print('Event successfully added to calendar');
  } else {
    print('Error creating event');
  }

  return createResult.isSuccess && (createResult.data?.isNotEmpty ?? false);
}

Future<Map<DateTime, List<Event>>> retrieveEvents(
    Calendar selectedCalendar, Map<DateTime, List<Event>> events) async {
  final calendarEventsResult = await deviceCalendarPlugin.retrieveEvents(
      selectedCalendar.id,
      RetrieveEventsParams(startDate: startDay, endDate: endDay));

  if (!calendarEventsResult.isSuccess || calendarEventsResult.data == null) {
    return {};
  }

  for (final event in calendarEventsResult.data!) {
    final dateTime =
        (event.start == null) ? DateTime.now() : stripTZTime(event.start!);
    print(dateTime);
    print(event.title);
    if (!events.containsKey(dateTime)) {
      events[dateTime] = [event];
    } else {
      events[dateTime]!.add(event);
    }
  }

  return events;
}
