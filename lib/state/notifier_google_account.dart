import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:format/format.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../infrastructure/google_api.dart';
import '../repository/mail_summerize.dart';

class SharedGoogleAccount extends ChangeNotifier {
  final googleAccountStorage = const FlutterSecureStorage();
  // final isAuthorizedStorage = const FlutterSecureStorage();
  Map<String, Map<String, String>> googleAccount = {};
  int numOfAccounts = 0;
  String selectedAccount = 'shinnosukeono0409@gmail.com';
  // List<GoogleSignInAccount> googleAccount = [];
  // List<bool> isAuthorized = [];

  SharedGoogleAccount();

  void onUpdate(GoogleSignInAccount account, bool authorized) async {
    final headers = await account.authHeaders;
    // print(headers);
    googleAccountStorage.write(key: account.email, value: jsonEncode(headers));
    // isAuthorizedStorage.write(
    // key: '${account.email}_auth', value: authorized.toString());
    numOfAccounts++;
    // print(account.email);
    // googleAccount.add(account);
    // isAuthorized.add(authorized);
    //notifyListeners();
  }

  Future<void> handleSignIn() async {
    // handleGoogleSignOut();
    setupGoogleSignInListener((account, authorized) {
      onUpdate(account!, authorized);
    });
    await handleGoogleSignInSilently();
    if (numOfAccounts == 0) {
      await handleGoogleSignIn();
    }
    //notifyListeners();
  }

  Future<void> addAccount() async {
    await handleGoogleSignIn();
  }

  // void handleAuthorizeScopes() {
  //   handleGoogleAuthorizeScopes((account, authorized) {
  //     isAuthorizedStorage.write(
  //         key: account.email, value: authorized.toString());
  //   }, googleAccount);
  // }

  Future<Map<String, String>?> searchHeaders(String email) async {
    final result = await googleAccountStorage.read(key: email);
    if (result == null) return null;
    return Map<String, String>.from(jsonDecode(result));
  }

  Future<void> readAllHeaders() async {
    final readAll = await googleAccountStorage.readAll();
    // print(readAll.length);
    readAll.forEach((key, value) {
      // print(key);
      // print(value);
      googleAccount[key] = Map<String, String>.from(jsonDecode(value));
      // print(googleAccount[key]);
      // print(googleAccount.length);
    });
  }
}

final googleAccountProvider =
    ChangeNotifierProvider((ref) => SharedGoogleAccount());

class SharedGMailData extends ChangeNotifier {
  Map<String, List<ListEmails>?> rawData = {};
  Map<String, List<ListSchedules>?> summarizedSchedule = {};
  Map<String, List<dynamic>> jsonSummarizedSchedule = {};
  Map<String, List<dynamic>> jsonSummarizedImportantSchedule = {};

  SharedGoogleAccount? googleAccount;

  SharedGMailData(this.googleAccount);

  Future<void> fetchMailData(String email, {bool notify = true}) async {
    rawData[email] = null;
    late Map<String, String>? headers;
    if (!googleAccount!.googleAccount.containsKey(email)) {
      headers = await googleAccount!.searchHeaders(email);
    } else {
      headers = googleAccount!.googleAccount[email];
    }

    if (headers == null) {
      rawData[email] = null;
    } else {
      try {
        rawData[email] = await fetchGMailsAsRaw(headers);
      } catch (e) {}
    }
    if (notify) notifyListeners();
  }

  void fetchAllMailData() {
    bool notifyFlag = true;
    googleAccount!.googleAccount.forEach((key, value) async {
      rawData[key] = null;
      await fetchMailData(key, notify: notifyFlag);
      if (notifyFlag) notifyFlag = false;
    });
  }

  Future<void> summarizeScheduleData(String email, {bool notify = true}) async {
    if (!rawData.containsKey(email)) await fetchMailData(email, notify: false);
    if (rawData[email] == null) {
      print('here');
      summarizedSchedule[email] = null;
    } else {
      print('there');
      summarizedSchedule[email] =
          await detectSchedulesFromRawTexts(rawData[email]!);
      print('finished');
      // print(summarizedSchedule[email]);
      // if (notify) notifyListeners();
    }
  }

  Future<void> summarizeAllScheduleData() async {
    for (final key in googleAccount!.googleAccount.keys) {
      print('key: ${key}');
      if (rawData[key] != null) await summarizeScheduleData(key);
    }
    print('all finished');
  }

  void jsonifySummarizedSchedule(String email) {
    if (!summarizedSchedule.containsKey(email)) {
      summarizeScheduleData(email);
    }

    if (summarizedSchedule[email] == null) {
      jsonSummarizedSchedule[email] == null;
    } else {
      jsonSummarizedSchedule[email] = summarizedSchedule[email]!.map((e) {
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
  }

  void extractImportantSchedule(String email) {
    if (jsonSummarizedSchedule.containsKey(email)) {
      jsonifySummarizedSchedule(email);
    }

    if (jsonSummarizedSchedule[email] == null) {
      jsonSummarizedImportantSchedule[email] == null;
    }

    jsonSummarizedImportantSchedule[email] = jsonSummarizedSchedule[email]!
        .where((item) => item['fixed'] is bool && item['fixed'])
        .toList();
  }
}

final gmailDataProvider = ChangeNotifierProvider((ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return SharedGMailData(googleAccount);
});
