import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mail_app/infrastructure/util.dart';
import '../infrastructure/google_api.dart';
import '../repository/mail_summarize.dart';

class SharedGoogleAccount extends ChangeNotifier {
  GoogleSignInAccount? googleAccount;
  bool isAuthorized = false;
  bool accountChanged = false;

  SharedGoogleAccount();

  void onUpdate(GoogleSignInAccount? account, bool authorized) {
    googleAccount = account;
    isAuthorized = authorized;
    accountChanged = true;
    //notifyListeners();
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
  List<ListSchedules>? summarizedSchedule;
  List<dynamic>? jsonSummarizedSchedule;
  List<dynamic>? jsonSummarizedImportantSchedule;
  bool failed = false;

  SharedGoogleAccount? googleAccount;

  SharedGMailData(this.googleAccount);

  Future<void> init(GoogleSignInAccount account) async {
    await fetchMailData(account);
    if (rawData == null) failed = true;
    await summarizeScheduleData();
    jsonifySummarizedSchedule();

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
    if (notify) notifyListeners();
  }

  /*
   * can't handle when the rawData is null because fetchMailData
   * need GoogleSignInAccount object.
   * Make sure fetchMailData has already been called before
   * call this function.
   */
  Future<void> summarizeScheduleData({bool notify = false}) async {
    summarizedSchedule =
        (rawData == null) ? null : await detectSchedulesFromRawTexts(rawData!);
    if (notify) notifyListeners();
  }

  void jsonifySummarizedSchedule({bool notify = false}) {
    jsonSummarizedSchedule = (summarizedSchedule == null)
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
