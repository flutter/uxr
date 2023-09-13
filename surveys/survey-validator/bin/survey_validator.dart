import 'dart:io';

import 'package:survey_validator/survey_validator.dart' as survey_validator;

void main(List<String> arguments) {
  final contextualSurveyFile =
      File('${Directory.current.path}/surveys/contextual-survey-metadata.json');

  survey_validator.checkJson(contextualSurveyFile);
}
