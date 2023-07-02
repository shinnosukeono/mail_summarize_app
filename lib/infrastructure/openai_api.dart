import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:dart_openai/dart_openai.dart';

String prompt(String rawText) {
  return 'I will show you the text of an email to you. If you detect any schedule in the email, please summarize them. If you do not detect any schedule, answer "No". Here is the format of the summary if any schedule are detected. It follows the JSON format: { "m": *month (integer), "d": *day (integer), "y": *year (integer. if not specified, the nearest year so that the specified month and date would be in the future), "ymd": *yyyy-mm-dd (string), "dow": *day of week (integer. 0 corresponds to Monday, 6 corresponds to Sunday.), "stime": start time (hh:mm. "" if not specified), "etime": end time (hh:mm. "" if not specified), "loc": location ("" if not specified), "summary": the summary of the event "fixed": if the event is fixed (needed to attend) or not}, (if multiple events are detected, continue...). The field specified with * must not be null. The body of the summary should be answered in Japanese. The key should remain in English. Do not include any newline characters in the response. The following is the text of the e-mail: $rawText';
}

Future<OpenAIChatCompletionModel> chatCompletion(String rawText) async {
  return await OpenAI.instance.chat.create(
    model: dotenv.get('OPENAI_API_MODEL'),
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: prompt(rawText),
        role: OpenAIChatMessageRole.user,
      ),
    ],
  );
}

Future<String?> summarizeSchedules(String rawText) async {
  OpenAIChatCompletionModel? chatResponse;
  try {
    //print('request sent');
    chatResponse = await chatCompletion(rawText);
  } catch (error) {
    debugPrint('Error summarizing the email: $error');
  }

  if (chatResponse == null) {
    return null;
  }

  String responseText = chatResponse.choices.last.message.content;
  if (responseText != 'No') {
    //print(responseText);
  } else {
    //print('No schedule detected');
  }

  //print('request complete');
  return responseText;
}
