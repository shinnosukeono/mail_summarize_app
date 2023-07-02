import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:mail_app/infrastructure/mobile_calendar.dart' as mc;
import 'package:mail_app/infrastructure/util.dart';

class SharedMobileCalendar extends ChangeNotifier {
  UnmodifiableListView<Calendar>? calendars;
  Calendar? defaultCalendar;
  Map<DateTime, List<Event>> events = {};

  Future<void> retrieveCalendars() async {
    calendars = await mc.retrieveCalendars();
  }

  Future<void> getDefaultCalendar() async {
    if (calendars == null) await retrieveCalendars();
    defaultCalendar = mc.getDefaultCalender(calendars!);
  }

  Future<bool> addEventToCalendar(Calendar? selectedCalendar, String summary,
      DateTime dtStart, DateTime dtEnd) async {
    if (selectedCalendar == null) {
      if (defaultCalendar == null) await getDefaultCalendar();
      selectedCalendar = defaultCalendar;
    }
    addSingleEventToList(selectedCalendar, summary, dtStart, dtEnd);
    return mc.addEventToCalendar(selectedCalendar!, summary, dtStart, dtEnd);
  }

  void addSingleEventToList(Calendar? selectedCalendar, String summary,
      DateTime dtStart, DateTime dtEnd) async {
    if (selectedCalendar == null) {
      if (defaultCalendar == null) await getDefaultCalendar();
      selectedCalendar = defaultCalendar;
    }

    final Event event = Event(
      selectedCalendar!.id,
      title: summary,
      start: tz.TZDateTime.from(dtStart, tz.local),
      end: tz.TZDateTime.from(dtEnd, tz.local),
    );

    DateTime key = stripDTTime(dtStart);

    if (!events.containsKey(key)) {
      events[key] = [event];
    } else {
      events[key]!.add(event);
    }
  }

  Future<void> retrieveEvents(Calendar? selectedCalendar) async {
    events = {};
    if (selectedCalendar == null) {
      if (defaultCalendar == null) await getDefaultCalendar();
      selectedCalendar = defaultCalendar;
    }
    /*
     * If events.isEmpty is still true after this function, that means
     * 1. we failed to retrieve events, or
     * 2. no events are registered in the calendar.
     */
    events = await mc.retrieveEvents(selectedCalendar!, events);
  }

  List<Event> eventLoader(DateTime day) {
    final key = stripDTTime(day);
    if (events.containsKey(key)) {
      return events[key]!;
    } else {
      return [];
    }
  }
}

final mobileCalendarProvider =
    ChangeNotifierProvider((ref) => SharedMobileCalendar());
