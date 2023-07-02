import 'package:device_calendar/device_calendar.dart';
import 'package:format/format.dart';
import 'dart:convert';
import '../repository/mail_summarize.dart';

List<dynamic>? jsonifySchedule(List<ListSchedules> schedule) {
  List<dynamic> list = schedule.map((e) {
    final json = jsonDecode(e.schedule);
    final d = json['d'].toString().padLeft(2, '0');
    final m = json['m'].toString().padLeft(2, '0');
    if (json['y'] == '') {
      json['y'] = DateTime.now().year.toString();
    }
    json['ymd'] = '{0}-{1}-{2}'.format(json['y'], m, d);

    if (json['stime'] != '') {
      late String stime;
      if (json['stime'].length != 5) {
        stime = '0{0}'.format(json['stime']);
      } else {
        stime = json['stime'];
      }
      json['dt_start'] = DateTime.parse('{0} {1}'.format(json['ymd'], stime));
    } else {
      json['dt_start'] = DateTime.parse(json['ymd']);
    }

    if (json['etime'] != '') {
      late String etime;
      if (json['etime'].length != 5) {
        etime = '0{0}'.format(json['etime']);
      } else {
        etime = json['etime'];
      }
      json['dt_end'] = DateTime.parse('{0} {1}'.format(json['ymd'], etime));
    } else {
      json['dt_end'] = DateTime.parse(json['ymd']);
    }

    json['id'] = e.id;
    return json;
  }).toList();

  list = sortSchedule(list);

  return list;
}

List<dynamic> sortSchedule(List<dynamic> schedule) {
  schedule.sort((a, b) {
    DateTime dateA = DateTime.parse(a['ymd']);
    DateTime dateB = DateTime.parse(b['ymd']);
    return dateA.compareTo(dateB);
  });

  return schedule;
}

DateTime stripTZTime(TZDateTime tzDateTime) {
  final parsedDateTime = DateTime.parse(tzDateTime.toIso8601String()).toLocal();
  return DateTime(
      parsedDateTime.year, parsedDateTime.month, parsedDateTime.day);
}

DateTime stripDTTime(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}
