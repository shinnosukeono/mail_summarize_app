import 'package:flutter/material.dart';

import '../icon/date_icon.dart';

Widget buildListTile(String title, int date, String dayOfWeek) {
  return Container(
    decoration: new BoxDecoration(
        border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
    child: ListTile(
      leading: buildDateIcon(date, dayOfWeek),
      title: Text(
        title,
        style: TextStyle(color: Colors.black, fontSize: 18.0),
      ),
    ),
  );
}
