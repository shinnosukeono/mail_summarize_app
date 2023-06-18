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

Future<String> detectSchedulesFromRawTexts(
    List<ListEmails> listRawTexts) async {
  String schedules = '[';
  for (ListEmails rawText in listRawTexts) {
    if (schedules != '[' && !schedules.endsWith(',')) {
      schedules += ',';
    }
    String preprocessedText = preprocessRawText(rawText);
    final summarizedText = await summarizeSchedules(preprocessedText);
    if (summarizedText != 'No') {
      schedules += summarizedText;
    }
  }
  schedules += ']';
  return schedules;
}

Future<String> detectSchedulesFromProcessedTexts(List<String> listTexts) async {
  String schedules = '[';
  for (String text in listTexts) {
    if (schedules != '[' && !schedules.endsWith(',')) {
      schedules += ',';
    }
    final summarizedText = await summarizeSchedules(text);
    if (summarizedText != 'No') {
      schedules += summarizedText;
    }
  }
  schedules += ']';
  return schedules;
}
