import 'package:flutter/material.dart';

final dayOfWeekMapping = {
  1: '月',
  2: '火',
  3: '水',
  4: '木',
  5: '金',
  6: '土',
  7: '日',
};

Widget buildDateIcon(dynamic jsonSummarizedSchedule) {
  late int dayOfWeek;
  try {
    dayOfWeek = DateTime.parse(jsonSummarizedSchedule['ymd']).weekday;
  } catch (e) {
    dayOfWeek = 0;
  }

  return CircleAvatar(
    backgroundColor: const Color.fromRGBO(38, 94, 149, 1.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          (dayOfWeek == 0) ? '' : dayOfWeekMapping[dayOfWeek]!,
          style: const TextStyle(fontSize: 8.0),
        ),
        Text(
          jsonSummarizedSchedule['d'].toString(),
          style: const TextStyle(fontSize: 12.0),
        ),
      ],
    ),
  );
}
