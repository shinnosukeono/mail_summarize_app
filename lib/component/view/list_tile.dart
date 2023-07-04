import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/button/mailview_popup.dart';
import 'package:mail_app/state/notifier_google_account.dart';
import 'package:mail_app/component/icon/date_icon.dart';

Widget buildMailListView(
    BuildContext context, WidgetRef ref, bool onlyImportantFlag) {
  final gmailData = ref.watch(gmailDataProvider);

  late dynamic jsonMailData;
  if (onlyImportantFlag) {
    jsonMailData = gmailData.jsonSummarizedImportantSchedule;
  } else {
    jsonMailData = gmailData.jsonSummarizedSchedule;
  }

  if (gmailData.failed) {
    return const Center(child: Text('fetch failed'));
  }

  if (jsonMailData == null || jsonMailData!.isEmpty) {
    //TODO: load more
    return const Center(child: Text('No mail data'));
  }

  return Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: ListView.builder(
      itemCount: jsonMailData!.length,
      itemBuilder: (context, index) {
        return buildListTile(
          context,
          ref,
          jsonMailData![index],
        );
      },
    ),
  );
}

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
