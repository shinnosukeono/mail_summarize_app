import '../infrastructure/google_api.dart';
import '../infrastructure/html_scraper.dart';
import '../infrastructure/openai_api.dart';

class ListSchedules {
  const ListSchedules({
    required this.id,
    required this.schedule,
  });

  final String id;
  final String schedule;
}

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

List<String> parseSchedules(String summarizedSchedule) {
  RegExp regExp = RegExp(r'\{.*?\}');
  Iterable<Match> matches = regExp.allMatches(summarizedSchedule);
  return matches.map((match) => match.group(0)!).toList();
}

Future<List<ListEmails>> fetchGMailsAsRaw(user) async {
  return await fetchGoogleEmails(user);
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

Future<List<ListSchedules>> detectSchedulesFromRawTexts(
    List<ListEmails> listRawTexts) async {
  List<Future<List<ListSchedules>?>> futures =
      listRawTexts.map((rawText) async {
    String? summarizedSchedule =
        await summarizeSchedules(preprocessRawText(rawText));
    if (summarizedSchedule == null) {
      return null;
    }
    List<String> parsedSchedules = parseSchedules(summarizedSchedule);
    return parsedSchedules.map((parsedSchedule) {
      print(parsedSchedule);
      return ListSchedules(
        id: rawText.id,
        schedule: parsedSchedule,
      );
    }).toList();
  }).toList();

  List<List<ListSchedules>?> nestedResults = await Future.wait(futures);
  List<ListSchedules> results =
      nestedResults.where((x) => x != null).expand((x) => x!).toList();
  return results;
}

/*
Future<List<ListSchedules>> detectSchedulesFromProcessedTexts(List<String> listTexts) async {
  List<Future<ListSchedules>> futures = listTexts.map((rawText) async {
    String summarizedSchedule =
        await summarizeSchedules(rawText);
    return ListSchedules(
      id: rawText.id,
      schedule: summarizedSchedule,
    );
  }).toList();
  return await Future.wait(futures);
}
*/
