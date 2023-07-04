import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/button/mailview_drawer.dart';
import 'package:mail_app/component/button/calendar_button.dart';
import 'package:mail_app/component/view/list_tile.dart';

class ListPage extends ConsumerWidget {
  final bool onlyImportantFlag;
  const ListPage({Key? key, this.onlyImportantFlag = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メール要約'),
        actions: [
          createCalendarButton(context),
          const SizedBox(
            width: 10, // 位置調整
          )
        ],
      ),
      drawer: buildDrawerMailListButton(context, ref),
      body: buildMailListView(context, ref, onlyImportantFlag),
    );
  }
}
