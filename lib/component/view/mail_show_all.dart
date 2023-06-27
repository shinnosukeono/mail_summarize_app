import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../state/notifier_google_account.dart';
import '../../infrastructure/google_api.dart';

class MailPage extends ConsumerWidget {
  final String id;
  const MailPage({required this.id, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gmailData = ref.watch(gmailDataProvider);
    ListEmails mail =
        gmailData.rawData!.firstWhere((element) => element.id == id);
    if (mail.mimeType == 'text/html') {
      return Scaffold(
          appBar: AppBar(
            title: const Text('メール本文'),
          ),
          body: WebView(
            initialUrl: Uri.dataFromString(
              mail.rawText,
              mimeType: mail.mimeType,
              encoding: Encoding.getByName('utf-8'),
            ).toString(),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('メール本文'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              mail.rawText,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      );
    }
  }
}
