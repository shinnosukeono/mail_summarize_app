import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mail_app/infrastructure/mobile_calendar.dart';
import 'package:mail_app/state/notifier_mobile_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarFormat _format = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now().toLocal();
  DateTime? _selectedDay;
  ValueNotifier<List<Event>>? _selectedEvents = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mobileCalendar = ref.read(mobileCalendarProvider);
      mobileCalendar.retrieveEvents(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobileCalendar = ref.watch(mobileCalendarProvider);
    _selectedEvents!.value = mobileCalendar.eventLoader(_selectedDay!);
    return Scaffold(
        appBar: AppBar(
          title: const Text('カレンダー'),
        ),
        body: Column(children: [
          TableCalendar(
            firstDay: startDay,
            lastDay: endDay,
            focusedDay: _focusedDay,
            calendarFormat: _format,
            eventLoader: (day) {
              return mobileCalendar.eventLoader(day);
            },
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.

              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                // Call `setState()` when updating the selected day
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedEvents!.value =
                      mobileCalendar.eventLoader(selectedDay);
                });
              }
            },
            onFormatChanged: (format) {
              if (_format != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _format = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                if (day.weekday == DateTime.sunday ||
                    day.weekday == DateTime.saturday) {
                  final text = DateFormat.E().format(day);
                  return Center(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return null;
                }
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents!,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index].title}'),
                        title: Text('${value[index].title}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]));
  }
}
