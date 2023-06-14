import '../infrastructure/google_api.dart';
import '../infrastructure/html_scraper.dart';
import '../infrastructure/openai_api.dart';

String preprocessRawText(ListEmails rawText) {
  late String preprocessedText;
  switch (rawText.mimeType) {
    case 'text/html':
      preprocessedText = htmlBodyScraper(rawText.rawText);
    case 'text/plain':
      preprocessedText = rawText.rawText;
    default:
      preprocessedText = rawText.rawText;
  }
  return preprocessedText;
}

Future<List<String>> fetchGMailsAsStr(user) async {
  List<ListEmails> listRawTexts = await fetchGoogleEmails(user);
  List<String> preprocessedTexts = [];
  for (ListEmails rawText in listRawTexts) {
    String preprocessedText = preprocessRawText(rawText);
    preprocessedTexts.add(preprocessedText);
  }
  return preprocessedTexts;
}

Future<List<String>> detectSchedulesFromRawTexts(
    List<ListEmails> listRawTexts) async {
  List<Future<String>> schedules = [];
  for (ListEmails rawText in listRawTexts) {
    String preprocessedText = preprocessRawText(rawText);
    var summarizedText = summarizeSchedules(preprocessedText);
    schedules.add(summarizedText);
  }
  return await Future.wait(schedules);
}

Future<List<String>> detectSchedulesFromProcessedTexts(
    List<String> listTexts) async {
  List<Future<String>> schedules = [];
  for (String text in listTexts) {
    var summarizedText = summarizeSchedules(text);
    schedules.add(summarizedText);
  }
  return await Future.wait(schedules);
}
