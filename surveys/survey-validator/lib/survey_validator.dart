import 'dart:convert';
import 'dart:io';

import 'package:unified_analytics/unified_analytics.dart';

/// The allowed action strings for a given button
const allowedButtonActions = {
  'accept',
  'dismiss',
  'snooze',
};

/// The allowed operators for a given condition item
const allowedConditionOperators = {
  '>=',
  '<=',
  '>',
  '<',
  '==',
  '!=',
};

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
const requiredKeys = {
  'uniqueId',
  'startDate',
  'endDate',
  'description',
  'snoozeForMinutes',
  'samplingRate',
  'conditions',
  'buttons',
  'excludeDashTools',
};

/// Regex pattern to verify a string is a valid v4 UUID.
final uuidRegexPattern = RegExp(
    r'^[0-9a-z]{8}\-[0-9a-z]{4}\-[0-9a-z]{4}\-[0-9a-z]{4}\-[0-9a-z]{12}$');

/// The valid dash tools stored in the [DashTool] enum
Set<String> get validDashTools => DashTool.values.map((e) => e.label).toSet();

void checkJson(File contextualSurveyFile) {
  final jsonContents = jsonDecode(contextualSurveyFile.readAsStringSync());

  if (jsonContents is! List) {
    throw ArgumentError('The json file must be a list');
  }

  for (final surveyObject in jsonContents) {
    // Ensure that each list item is a json object / map
    if (surveyObject is! Map) {
      throw ArgumentError('Each item in the array must be a map');
    }

    // Ensure that the number of keys found in each object is correct
    if (surveyObject.keys.length != requiredKeys.length) {
      throw ArgumentError(
          'There should only be ${requiredKeys.length} keys per survey object\n'
          'The required keys are: ${requiredKeys.join(', ')}');
    }

    // Ensure that the keys themselves match what has been defined
    final surveyObjectKeySet = surveyObject.keys.toSet();
    if (surveyObjectKeySet.intersection(requiredKeys).length !=
        requiredKeys.length) {
      throw ArgumentError('Missing the following keys: '
          '${requiredKeys.difference(surveyObjectKeySet).join(', ')}');
    }

    final uniqueId = surveyObject['uniqueId'] as String;
    final startDate = DateTime.parse(surveyObject['startDate'] as String);
    final endDate = DateTime.parse(surveyObject['endDate'] as String);
    final description = surveyObject['description'] as String;
    final snoozeForMinutes = surveyObject['snoozeForMinutes'] as int;
    final samplingRate = surveyObject['samplingRate'] as double;
    final excludeDashToolsList = surveyObject['excludeDashTools'] as List;
    final conditionList = surveyObject['conditions'] as List;
    final buttonList = surveyObject['buttons'] as List;

    // Ensure all of the string values are not empty
    if (uniqueId.isEmpty) {
      throw ArgumentError('Unique ID cannot be an empty string');
    }
    if (description.isEmpty) {
      throw ArgumentError('Description cannot be an empty string');
    }

    // Ensure that the survey's ID is a valid v4 UUID.
    if (!uuidRegexPattern.hasMatch(uniqueId)) {
      throw ArgumentError('Ensure that the unique ID for the survey is '
          'valid UUID v4 format for survey: $uniqueId\n'
          'Example: eca0100a-505b-4539-96d0-57235f816cef');
    }

    // Validation on the periods
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('End date is before the start date');
    }

    // Ensure the numbers are greater than zero and valid
    if (snoozeForMinutes <= 0) {
      throw ArgumentError('Snooze minutes must be greater than 0');
    }
    if (samplingRate <= 0 || samplingRate > 1.0) {
      throw ArgumentError('Sampling rate must be between 0 and 1 inclusive');
    }

    // Validation on the array containing dash tools to exclude
    for (final excludeDashTool in excludeDashToolsList) {
      if (excludeDashTool is! String) {
        throw ArgumentError(
            'Each dash tool in the exclude list must be a string');
      }

      if (!validDashTools.contains(excludeDashTool)) {
        throw ArgumentError(
            'The excluded dash tool: "$excludeDashTool" is not valid\n'
            'Valid dash tools are: ${validDashTools.join(', ')}');
      }
    }

    // Validation on the condition array
    for (final conditionObject in conditionList) {
      if (conditionObject is! Map) {
        throw ArgumentError('Each item in the condition array must '
            'be a map for survey: $uniqueId');
      }
      if (conditionObject.keys.length != conditionRequiredKeys.length) {
        throw ArgumentError('Each condition object should only have '
            '${conditionRequiredKeys.length} keys');
      }

      final field = conditionObject['field'] as String;
      final operator = conditionObject['operator'] as String;
      final value = conditionObject['value'] as int;

      if (field.isEmpty) {
        throw ArgumentError('Field in survey: $uniqueId must not be empty');
      }
      if (!allowedConditionOperators.contains(operator)) {
        throw ArgumentError(
            'Non-valid operator found in condition for survey: $uniqueId');
      }
      if (value < 0) {
        throw ArgumentError('Value for each condition must not be negative');
      }
    }

    // Validation on the button array
    final buttonTextSet = <String>{};
    for (final buttonObject in buttonList) {
      if (buttonObject is! Map) {
        throw ArgumentError('Each item in the button array must '
            'be a map for survey: $uniqueId');
      }
      if (buttonObject.keys.length != buttonRequiredKeys.length) {
        throw ArgumentError('Each button object should only have '
            '${buttonRequiredKeys.length} keys');
      }

      final buttonText = buttonObject['buttonText'] as String;
      final action = buttonObject['action'] as String;
      final url = buttonObject['url'] as String?;
      // ignore: unused_local_variable
      final promptRemainsVisible = buttonObject['promptRemainsVisible'] as bool;

      if (buttonText.isEmpty) {
        throw ArgumentError(
            'Cannot have empty text for a given button in survey: $uniqueId');
      }
      if (!allowedButtonActions.contains(action)) {
        throw ArgumentError('The action: "$action" is not allowed');
      }
      if (url != null && url.isEmpty) {
        throw ArgumentError('URL values must be a non-empty string or "null"');
      }

      // If a given button has "dismiss" as the action,
      // there should be no URL defined.
      if (action == 'dismiss' && url != null) {
        throw ArgumentError('URL should be null if action for a button is '
            '"dismiss" or "snooze" for survey: $uniqueId');
      }

      // Add the button text to a set to ensure that
      // each button in a survey has a unique label.
      buttonTextSet.add(buttonText);
    }

    if (buttonTextSet.length != buttonList.length) {
      throw ArgumentError(
          'Each button must have unique text in survey: $uniqueId');
    }
  }
}
