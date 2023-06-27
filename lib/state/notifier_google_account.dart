import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:format/format.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../infrastructure/google_api.dart';
import '../repository/mail_summerize.dart';

class SharedGoogleAccount extends ChangeNotifier {
  GoogleSignInAccount? googleAccount;
  bool isAuthorized = false;

  SharedGoogleAccount();

  void onUpdate(GoogleSignInAccount account, bool authorized) {
    googleAccount = account;
    isAuthorized = authorized;
    //notifyListeners();
  }

  Future<void> handleSignIn() async {
    setupGoogleSignInListener((account, authorized) {
      onUpdate(account!, authorized);
    });
    await handleGoogleSignInSilently();
    if (googleAccount == null) {
      await handleGoogleSignIn();
    }
    //notifyListeners();
  }

  void handleAuthorizeScopes() {
    handleGoogleAuthorizeScopes((authorized) {
      isAuthorized = authorized;
    }, googleAccount);
  }
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
    jsonSummarizedSchedule = summarizedSchedule!.map((e) {
      final json = jsonDecode(e.schedule);
      final d = json['d'].toString().padLeft(2, '0');
      final m = json['m'].toString().padLeft(2, '0');
      if (json['y'] == '') {
        json['y'] = DateTime.now().year.toString();
      }
      json['ymd'] = '{0}-{1}-{2}'.format(json['y'], m, d);
      json['dt_start'] = DateTime.parse(json['ymd']);
      if (json['stime'] != '') {
        json['dt_start'] =
            DateTime.parse('{0} {1}'.format(json['ymd'], json['stime']));
      } else {
        json['dt_start'] = DateTime.parse(json['ymd']);
      }

      if (json['etime'] != '') {
        json['dt_end'] =
            DateTime.parse('{0} {1}'.format(json['ymd'], json['etime']));
      } else {
        json['dt_end'] = DateTime.parse(json['ymd']);
      }

      json['id'] = e.id;
      return json;
    }).toList();
  }

  void extractImportantSchedule() {
    if (jsonSummarizedSchedule == null) {
      jsonifySummarizedSchedule();
    }
    jsonSummarizedImportantSchedule = jsonSummarizedSchedule!
        .where((item) => item['fixed'] is bool && item['fixed'])
        .toList();
  }
}

final gmailDataProvider = ChangeNotifierProvider((ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return SharedGMailData(googleAccount);
});
