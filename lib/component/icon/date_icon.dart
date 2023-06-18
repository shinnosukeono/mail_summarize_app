import 'package:flutter/material.dart';

Widget buildDateIcon(int date, String dayOfWeek) {
  // 日付と曜日を元にアイコンを生成する処理を書くことができます
  // ここでは仮に日付と曜日をテキストとして表示するアイコンを生成しています
  return CircleAvatar(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayOfWeek,
          style: const TextStyle(fontSize: 8.0),
        ),
        Text(
          date.toString(),
          style: const TextStyle(fontSize: 12.0),
        ),
      ],
    ),
  );
}
