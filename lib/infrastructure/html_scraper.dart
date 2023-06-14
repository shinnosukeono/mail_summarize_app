import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

String htmlBodyScraper(String html) {
  Document document = parser.parse(html);

  Element bodyElement = document.querySelector('body')!;
  //print('Body: ${bodyElement.text}');
  return bodyElement.text;
}
