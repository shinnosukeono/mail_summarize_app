import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/state/notifier_google_account.dart';
import '/component/view/add_event_dialog.dart';
import '/component/view/mail_show_all.dart';
import 'package:mail_app/state/notifier_mobile_calendar.dart';

Widget buildPopupMailListMenuButton(
    BuildContext context, WidgetRef ref, dynamic jsonSummarizedSchedule) {
  final mobileCalendar = ref.watch(mobileCalendarProvider);
  final googleAccount = ref.watch(googleAccountProvider);
  return PopupMenuButton<int>(
      itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.read_more),
                  Text('元メールを表示'),
                ],
              ),
            ),
            const PopupMenuItem(
                value: 2,
                child: Row(children: [
                  Icon(Icons.add_alarm),
                  Text('カレンダーに追加'),
                ])),
          ],
      onSelected: (value) async {
        switch (value) {
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MailPage(
                      id: jsonSummarizedSchedule['id'],
                      selectedAccount: googleAccount.selectedAccount)),
            );
          case 2:
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TextEditingDialog(
                      jsonSummarizedSchedule: jsonSummarizedSchedule)),
            );
            if (result != null) {
              mobileCalendar.addEventToCalendar(null, result['summary'],
                  result['dt_start'], result['dt_end']);
            }
          default:
            break;
        }
      });
}
