import 'dart:io';
import 'dart:convert';

void main() {
  final contextualSurveyFile = File('surveys/contextual-survey-metadata.json');
  final jsonContents = jsonDecode(contextualSurveyFile.readAsStringSync());

  print(jsonContents);
}
