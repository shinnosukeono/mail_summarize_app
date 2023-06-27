import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/button/mailview_popup.dart';

import '/component/icon/date_icon.dart';

Widget buildListTile(
    BuildContext context, WidgetRef ref, jsonSummarizedSchedule) {
  return Container(
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
    child: ListTile(
      leading: buildDateIcon(jsonSummarizedSchedule),
      title: Text(
        jsonSummarizedSchedule['summary'],
        style: const TextStyle(color: Colors.black, fontSize: 18.0),
      ),
      trailing:
          buildPopupMailListMenuButton(context, ref, jsonSummarizedSchedule),
    ),
  );
}
