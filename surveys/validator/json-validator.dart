import 'dart:io';
import 'dart:convert';

/// The allowed action strings for a given button
final allowedButtonActions = [
  'accept',
  'dismiss',
  'snooze',
];

/// The allowed operators for a given condition item
const allowedConditionOperators = [
  '>=',
  '<=',
  '>',
  '<',
  '==',
  '!=',
];

/// Required keys for the button object
const buttonRequiredKeys = [
  'buttonText',
  'action',
  'url',
  'promptRemainsVisible',
];

/// Required keys for the condition object
const conditionRequiredKeys = [
  'field',
  'operator',
  'value',
];

/// The top level keys that must exist for each json object
/// in the array
const requiredKeys = [
  'uniqueId',
  'startDate',
  'endDate',
  'description',
  'snoozeForMinutes',
  'samplingRate',
  'conditions',
  'buttons',
];

void main() {
  final contextualSurveyFile = File('surveys/contextual-survey-metadata.json');
  final jsonContents = jsonDecode(contextualSurveyFile.readAsStringSync());

  if (!(jsonContents is List)) throw ('The json file must be a list');

  jsonContents.forEach((surveyObject) {
    // Ensure that each list item is a json object / map
    if (!(surveyObject is Map)) throw ('Each item in the array must be a map');

    // Ensure that the number of keys found in each object is correct
    if (surveyObject.keys.length != requiredKeys.length)
      throw ('There should only be ${requiredKeys.length} keys per survey object');

    // Ensure that the keys themselves match what has been defined
    if (surveyObject.keys.toSet().intersection(requiredKeys.toSet()).length !=
        requiredKeys.length)
      throw ('Missing the following keys: '
          '${requiredKeys.toSet().difference(surveyObject.keys.toSet()).join(', ')}');

    final uniqueId = surveyObject['uniqueId'] as String;
    final startDate = DateTime.parse(surveyObject['startDate'] as String);
    final endDate = DateTime.parse(surveyObject['endDate'] as String);
    final description = surveyObject['description'] as String;
    final snoozeForMinutes = surveyObject['snoozeForMinutes'] as int;
    final samplingRate = surveyObject['samplingRate'] as double;
    final conditionList = surveyObject['conditions'] as List;
    final buttonList = surveyObject['buttons'] as List;

    // Ensure all of the string values are not empty
    if (uniqueId.isEmpty) throw ('Unique ID cannot be an empty string');
    if (description.isEmpty) throw ('Description cannot be an empty string');

    // Validation on the periods
    if (startDate.isAfter(endDate)) throw ('End date is before the start date');

    // Ensure the numbers are greater than zero
    if (snoozeForMinutes == 0) throw ('Snooze minutes must be greater than 0');
    if (samplingRate == 0) throw ('Sampling rate must be greater than 0');

    // Validation on the condition array
    conditionList.forEach((conditionObject) {
      if (!(conditionObject is Map))
        throw ('Each item in the condition array must '
            'be a map for survey: ${uniqueId}');
      if (conditionObject.keys.length != conditionRequiredKeys.length)
        throw ('Each condition object should only have '
            '${conditionRequiredKeys.length} keys');

      final field = conditionObject['field'] as String;
      final operator = conditionObject['operator'] as String;
      final value = conditionObject['value'] as int;

      if (field.isEmpty) throw ('Field in survey: $uniqueId must not be empty');
      if (!allowedConditionOperators.contains(operator))
        throw ('Non-valid operator found in condition for survey: $uniqueId');
      if (value < 0) throw ('Value for each condition must not be negative');
    });

    // Validation on the button array
    buttonList.forEach((buttonObject) {
      if (!(buttonObject is Map))
        throw ('Each item in the button array must '
            'be a map for survey: ${uniqueId}');
      if (buttonObject.keys.length != buttonRequiredKeys.length)
        throw ('Each button object should only have '
            '${buttonRequiredKeys.length} keys');

      final buttonText = buttonObject['buttonText'] as String;
      final action = buttonObject['action'] as String;
      final url = buttonObject['url'] as String?;
      // ignore: unused_local_variable
      final promptRemainsVisible = buttonObject['promptRemainsVisible'] as bool;

      if (buttonText.isEmpty)
        throw ('Cannot have empty text for a given button in survey: $uniqueId');
      if (!allowedButtonActions.contains(action))
        throw ('The action: "$action" is not allowed');
      if (url != null && url.isEmpty)
        throw ('URL values must be a non-empty string or "null"');
    });
  });
}
