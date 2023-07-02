import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/state/notifier_google_account.dart';
import 'package:mail_app/widget/list_presentation.dart';
import 'package:mail_app/widget/startup_screen.dart';

Widget buildDrawerMailListButton(BuildContext context, WidgetRef ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return Drawer(
    child: ListView(
      // padding: EdgeInsets.zero,
      children: <Widget>[
        const ListTile(
          title: Text('フォルダ'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_outlined),
          title: const Text('予定（すべて）'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ListPageSimple(
                onlyImportantFlag: false,
              );
            }));
          },
        ),
        ListTile(
          leading: const Icon(Icons.crisis_alert),
          title: const Text('予定（重要）'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ListPageSimple(
                onlyImportantFlag: true,
              );
            }));
          },
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Divider(
            color: Colors.grey,
            height: 0,
          ),
        ),
        const ListTile(
          title: Text('アカウント'),
        ),
        ListTile(
          leading: const Icon(Icons.output_outlined),
          title: const Text('ログアウト'),
          onTap: () {
            googleAccount.handleSignOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const StartUpPage(
                explicit: true,
              );
            }));
          },
        ),
      ],
    ),
  );
}
