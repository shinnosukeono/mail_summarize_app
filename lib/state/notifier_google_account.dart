import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:format/format.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mail_app/infrastructure/util.dart';
import 'package:mail_app/infrastructure/google_api.dart';
import 'package:mail_app/infrastructure/sqlite.dart';
import 'package:mail_app/repository/mail_summarize.dart';
import 'package:sqflite/sqflite.dart';

class SharedGoogleAccount extends ChangeNotifier {
  GoogleSignInAccount? googleAccount;
  bool isAuthorized = false;
  bool accountChanged = false;

  SharedGoogleAccount();

  void onUpdate(GoogleSignInAccount? account, bool authorized) {
    googleAccount = account;
    isAuthorized = authorized;
    accountChanged = true;
    // notifyListeners();
  }

  Future<void> handleSignIn() async {
    setupGoogleSignInListener((account, authorized) {
      onUpdate(account, authorized);
    });
    await handleGoogleSignInSilently();
    if (googleAccount == null) {
      await handleGoogleSignIn();
    }
    //notifyListeners();
  }

  Future<void> handleSignInExplicitly() async {
    setupGoogleSignInListener((account, authorized) {
      onUpdate(account, authorized);
    });
    await handleGoogleSignIn();
    // notifyListeners();
  }

  void handleAuthorizeScopes() {
    handleGoogleAuthorizeScopes((authorized) {
      isAuthorized = authorized;
    }, googleAccount);
  }

  Future<void> handleSignOut() => handleGoogleSignOut();
}

final googleAccountProvider =
    ChangeNotifierProvider((ref) => SharedGoogleAccount());

class SharedGMailData extends ChangeNotifier {
  List<ListEmails>? rawData;
  List<String>? idList;
  List<ListSchedules>? summarizedSchedule;
  List<dynamic>? jsonSummarizedSchedule;
  List<dynamic>? jsonSummarizedImportantSchedule;
  Database? database;
  List<ListSchedules>? prevSummarizedSchedule;
  bool failed = false;

  SharedGoogleAccount? googleAccount;

  SharedGMailData(this.googleAccount);

  Future<void> init(GoogleSignInAccount account) async {
    await fetchMailData(account);
    if (rawData == null) failed = true;
    if (await checkDatabaseExists(account.email)) {
      print('database exists');
      database = await connectToDataBase(account.email);
    }
    await summarizeScheduleData();
    jsonifySummarizedSchedule();

    if (database == null) {
      print('database does not exist');
      database = await createDataBase(account.email);
      writeBackScheduleData(null);
    }

    /*
     * Here, we can consider the information of the account
     * and the mail data to be fully synced.
     */
    if (googleAccount!.accountChanged) googleAccount!.accountChanged = false;
    // print('init finished');
    // print('failed: ${failed}');
    // print('accountChanged: ${googleAccount!.accountChanged}');
  }

  Future<void> fetchMailData(GoogleSignInAccount account,
      {bool notify = false}) async {
    rawData = await fetchGMailsAsRaw(account);
    if (rawData != null) {
      idList = rawData!.map((e) => e.id).toList();
    }
    if (notify) notifyListeners();
  }

  /*
   * can't handle when the rawData is null because fetchMailData
   * need GoogleSignInAccount object.
   * Make sure fetchMailData has already been called before
   * call this function.
   */
  Future<void> summarizeScheduleData({bool notify = false}) async {
    if (database != null && rawData != null) {
      prevSummarizedSchedule = await getDataFromIDList(database!, idList!);
      print('length of the database: {}'.format(
          prevSummarizedSchedule == null ? 0 : prevSummarizedSchedule!.length));
    }

    summarizedSchedule = null;
    if (rawData != null) {
      summarizedSchedule = [];
      if (prevSummarizedSchedule != null) {
        final List<ListEmails> rawDataNoMatch = rawData!.where((e) {
          final List<ListSchedules> match =
              prevSummarizedSchedule!.where((element) {
            if (element.id == e.id) {
              return true;
            } else {
              return false;
            }
          }).toList();
          if (match.isNotEmpty) {
            summarizedSchedule!.addAll(match);
            return false;
          } else {
            return true;
          }
        }).toList();

        if (rawDataNoMatch.isNotEmpty) {
          final List<ListSchedules> newSchedule =
              await detectSchedulesFromRawTexts(rawDataNoMatch);
          if (newSchedule.isNotEmpty) {
            summarizedSchedule!.addAll(newSchedule);
            writeBackScheduleData(newSchedule);
          }
        }
      } else {
        summarizedSchedule!.addAll(await detectSchedulesFromRawTexts(rawData!));
        writeBackScheduleData(null);
      }
    }

    if (notify) notifyListeners();
  }

  Future<void> writeBackScheduleData(List<ListSchedules>? schedule) async {
    schedule ??= summarizedSchedule;

    if (database != null && schedule != null) {
      insertData(database!, schedule);
    }
  }

  void jsonifySummarizedSchedule({bool notify = false}) {
    jsonSummarizedSchedule =
        (summarizedSchedule == null || summarizedSchedule!.isEmpty)
            ? null
            : jsonifySchedule(summarizedSchedule!);
    extractImportantSchedule();
    if (notify) notifyListeners();
  }

  void extractImportantSchedule() {
    jsonSummarizedImportantSchedule = (jsonSummarizedSchedule == null)
        ? null
        : jsonSummarizedSchedule!
            .where((item) => item['fixed'] is bool && item['fixed'])
            .toList();
  }
}

final gmailDataProvider = ChangeNotifierProvider((ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return SharedGMailData(googleAccount);
});
