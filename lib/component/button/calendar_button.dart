import 'package:flutter/material.dart';

import 'package:mail_app/widget/calendar_screen.dart';

Widget createCalendarButton(BuildContext context) {
  return GestureDetector(
    child: const Icon(Icons.calendar_today_outlined),
    onTap: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CalendarPage()));
    },
  );
}
