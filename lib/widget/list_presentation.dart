import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/button/mailview_drawer.dart';
import 'package:mail_app/component/view/list_tile.dart';
import 'package:mail_app/state/notifier_google_account.dart';

class ListPage extends ConsumerWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAccount = ref.watch(googleAccountProvider);
    final gmailData = ref.watch(gmailDataProvider);

    /*
     * gmailData.fetchMailData notifies when fetching completes,
     * resulting in this if clause to be skipped.
     */
    if (gmailData.rawData.isEmpty) {
      gmailData.fetchAllMailData();
      return Scaffold(
          appBar: AppBar(
            title: const Text('email loading'),
          ),
          body: const CircularProgressIndicator());
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('email summarizing'),
        ),
        drawer: buildDrawerMailListButton(context),
        body: FutureBuilder(
            future: gmailData.summarizeAllScheduleData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                //TODO: error handling
                return Text('Error: ${snapshot.error}');
              } else {
                gmailData.summarizedSchedule.forEach((key, value) {
                  gmailData.jsonifySummarizedSchedule(key);
                });
                final jsonMailData = gmailData
                    .jsonSummarizedSchedule[googleAccount.selectedAccount];
                // jsonMailData.sort((a, b) {
                //   DateTime dateA = DateTime.parse(a['ymd']);
                //   DateTime dateB = DateTime.parse(b['ymd']);
                //   return dateA.compareTo(dateB);
                // });
                return MailListView(
                    context: context, jsonMailData: jsonMailData);
              }
            }));
  }
}

class ListPageSimple extends ConsumerWidget {
  final bool onlyImportantFlag;
  const ListPageSimple({Key? key, required this.onlyImportantFlag})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAccount = ref.watch(googleAccountProvider);
    final gmailData = ref.watch(gmailDataProvider);

    late dynamic jsonMailData;
    if (onlyImportantFlag) {
      gmailData.extractImportantSchedule(googleAccount.selectedAccount);
      jsonMailData = gmailData
          .jsonSummarizedImportantSchedule[googleAccount.selectedAccount];
    } else {
      jsonMailData =
          gmailData.jsonSummarizedSchedule[googleAccount.selectedAccount];
    }

    /*
     * gmailData.fetchMailData notifies when fetching completes,
     * resulting in this if clause to be skipped.
     */
    if (gmailData.rawData.isEmpty) {
      gmailData.fetchMailData(googleAccount.selectedAccount);
      return Scaffold(
          appBar: AppBar(
            title: const Text('email loading'),
          ),
          body: const CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('email summarizing'),
      ),
      drawer: buildDrawerMailListButton(context),
      body: MailListView(context: context, jsonMailData: jsonMailData),
    );
  }
}

class MailListView extends ConsumerWidget {
  final List<dynamic>? jsonMailData;
  final BuildContext context;

  const MailListView({Key? key, required this.context, this.jsonMailData})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jsonMailData == null || jsonMailData!.isEmpty) {
      //TODO: load more
      return const Center(child: Text('No mail data'));
    }

    jsonMailData!.sort((a, b) {
      DateTime dateA = DateTime.parse(a['ymd']);
      DateTime dateB = DateTime.parse(b['ymd']);
      return dateA.compareTo(dateB);
    });

    return ListView.builder(
      itemCount: jsonMailData!.length,
      itemBuilder: (context, index) {
        return buildListTile(
          context,
          ref,
          jsonMailData![index],
        );
      },
    );
  }
}
