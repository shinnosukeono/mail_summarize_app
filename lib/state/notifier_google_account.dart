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

  SharedGoogleAccount? googleAccount;

  SharedGMailData(this.googleAccount);

  Future<void> fetchMailData(GoogleSignInAccount account) async {
    if (googleAccount!.accountChanged) googleAccount!.accountChanged = false;
    rawData = await fetchGMailsAsRaw(account);
    notifyListeners();
  }

  /*
   * can't handle when the rawData is null because fetchMailData
   * need GoogleSignInAccount object.
   * Make sure fetchMailData has already been called before
   * call this function.
   */
  Future<void> summarizedScheduleData() async {
    summarizedSchedule = await detectSchedulesFromRawTexts(rawData!);
    //notifyListeners();
  }

  void jsonifySummarizedSchedule() {
    if (summarizedSchedule == null) {
      summarizedScheduleData();
    }

    jsonSummarizedSchedule = jsonifySchedule(summarizedSchedule!);

    extractImportantSchedule();
  }

  void extractImportantSchedule() {
    jsonSummarizedImportantSchedule = jsonSummarizedSchedule!
        .where((item) => item['fixed'] is bool && item['fixed'])
        .toList();
  }
}

final gmailDataProvider = ChangeNotifierProvider((ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return SharedGMailData(googleAccount);
});
