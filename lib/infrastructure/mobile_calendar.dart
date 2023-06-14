import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  //late List<Calendar> _calendars;
  late Calendar _selectedCalendar;
  late Calendar? _defaultCalendar;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _getDefaultCalender(),
          builder: (BuildContext context, AsyncSnapshot<Calendar> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
                style: TextStyle(fontSize: 32),
              );
            }

            if (snapshot.hasData) {
              return Column(
                children: [
                  Text(
                    "DefaultCalendar: ${snapshot.data!.name}",
                    style: TextStyle(fontSize: 32),
                  )
                ],
              );
            } else {
              return const Text(
                "データが存在しません",
                style: TextStyle(fontSize: 32),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressedAddButton,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// デフォルト設定のカレンダーを取得する
  Future<Calendar> _getDefaultCalender() async {
    // カレンダーの許可があるか確認、なければ取得する
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        throw Exception("Not granted access to your calendar");
      }
    }

    // スマホ内のカレンダー一覧を取得する
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult?.data;
    if (calendars == null || calendars.isEmpty) {
      throw Exception("Can not get calendars.\n"
          "Emulatorを使用している場合で、カレンダーを使用したことがない場合、取得に失敗します。\n"
          "Emulatorからカレンダーアプリを開いて、ログインしてからコードを実行してください。");
    }

    // カレンダー一覧の中からデフォルト設定のカレンダーを取得する
    _defaultCalendar =
        calendars!.firstWhere((element) => element.isDefault ?? false);
    return _defaultCalendar!;
  }

  void _onPressedAddButton() {
    if (_defaultCalendar == null || _defaultCalendar!.id == null) {
      return;
    }

    // イベント追加ページへ遷移する
    //context.goNamed(
    //  "addEventPage",
    //  params: {'defaultCalendarId': _defaultCalendar!.id!},
    //);
  }
}
