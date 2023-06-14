import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:dart_openai/dart_openai.dart';

String prompt(String rawText) {
  return 'I will show you the text of an email to you. If you detect any schedule in the email, please summarize them. If you do not detect any schedule, answer "No". Here is the format of the summary if any schedule are detected. It follows the JSON format: { "date": date, "time": time, "location": location, "summary": the summary of the event }. The body of the summary should be answered in Japanese. The key should remain in English. The following is the text of the e-mail: $rawText';
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

Future<String> summarizeSchedules(String rawText) async {
  late OpenAIChatCompletionModel chatResponse;
  try {
    chatResponse = await chatCompletion(rawText);
  } catch (error) {
    debugPrint('Error summarizing the email: $error');
  }

  String responseText = chatResponse.choices.last.message.content;
  if (responseText != 'No') {
    //print(responseText);
  } else {
    //print('No schedule detected');
  }

  return responseText;
}