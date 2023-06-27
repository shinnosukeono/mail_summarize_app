import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';

import '../infrastructure/mobile_calendar.dart' as mc;

class SharedMobileCalendar extends ChangeNotifier {
  UnmodifiableListView<Calendar>? calendars;
  Calendar? defaultCalendar;

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
    return mc.addEventToCalendar(selectedCalendar!, summary, dtStart, dtEnd);
  }
}

final mobileCalendarProvider =
    ChangeNotifierProvider((ref) => SharedMobileCalendar());
