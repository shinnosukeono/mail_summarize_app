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
    if (gmailData.rawData == null) {
      /*
       * googleAccount.googleAccount can't be null because ListPage 
       * is always called by StartUpPage(startup_screen.dart), 
       * which checks if the sign in process succeeds.
       */
      gmailData.fetchMailData(googleAccount.googleAccount!);
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
            future: gmailData.summarizedScheduleData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                //TODO: error handling
                return Text('Error: ${snapshot.error}');
              } else {
                gmailData.jsonifySummarizedSchedule();
                final jsonMailData = gmailData.jsonSummarizedSchedule!;
                jsonMailData.sort((a, b) {
                  DateTime dateA = DateTime.parse(a['ymd']);
                  DateTime dateB = DateTime.parse(b['ymd']);
                  return dateA.compareTo(dateB);
                });
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
      jsonMailData = gmailData.jsonSummarizedImportantSchedule;
    } else {
      jsonMailData = gmailData.jsonSummarizedSchedule;
    }

    /*
     * gmailData.fetchMailData notifies when fetching completes,
     * resulting in this if clause to be skipped.
     */
    if (gmailData.rawData == null) {
      gmailData.fetchMailData(googleAccount.googleAccount!);
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
