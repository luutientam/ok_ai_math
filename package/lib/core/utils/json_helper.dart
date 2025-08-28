import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// A utility class for handling JSON operations
class JsonHelper {
  /// Converts a Map to JSON string
  static String mapToJson(Map<String, dynamic> map) {
    try {
      return json.encode(map);
    } catch (e) {
      developer.log('Error encoding map to JSON: $e');
      return '{}';
    }
  }

  /// Converts a JSON string to Map
  static Map<String, dynamic> jsonToMap(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error decoding JSON to map: $e');
      return {};
    }
  }

  /// Converts a List to JSON string
  static String listToJson(List<dynamic> list) {
    try {
      return json.encode(list);
    } catch (e) {
      developer.log('Error encoding list to JSON: $e');
      return '[]';
    }
  }

  /// Converts a JSON string to List
  static List<dynamic> jsonToList(String jsonString) {
    try {
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      developer.log('Error decoding JSON to list: $e');
      return [];
    }
  }

  /// Pretty prints JSON with indentation
  static String prettyPrint(dynamic jsonObject) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      developer.log('Error pretty printing JSON: $e');
      return jsonObject.toString();
    }
  }

  /// Validates if a string is valid JSON
  static bool isValidJson(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Safely gets a value from a Map with a default fallback
  static T? safeGet<T>(
    Map<String, dynamic> map,
    String key, [
    T? defaultValue,
  ]) {
    try {
      if (map.containsKey(key) && map[key] is T) {
        return map[key] as T;
      }
      return defaultValue;
    } catch (e) {
      developer.log('Error getting value for key $key: $e');
      return defaultValue;
    }
  }

  /// Safely gets a string value from a Map
  static String safeGetString(
    Map<String, dynamic> map,
    String key, [
    String defaultValue = '',
  ]) {
    return safeGet<String>(map, key, defaultValue) ?? defaultValue;
  }

  /// Safely gets an int value from a Map
  static int safeGetInt(
    Map<String, dynamic> map,
    String key, [
    int defaultValue = 0,
  ]) {
    final value = map[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely gets a double value from a Map
  static double safeGetDouble(
    Map<String, dynamic> map,
    String key, [
    double defaultValue = 0.0,
  ]) {
    final value = map[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely gets a bool value from a Map
  static bool safeGetBool(
    Map<String, dynamic> map,
    String key, [
    bool defaultValue = false,
  ]) {
    final value = map[key];
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return defaultValue;
  }

  /// Safely gets a List from a Map
  static List<T> safeGetList<T>(
    Map<String, dynamic> map,
    String key, [
    List<T> defaultValue = const [],
  ]) {
    try {
      final value = map[key];
      if (value is List) {
        return value.cast<T>();
      }
      return defaultValue;
    } catch (e) {
      developer.log('Error getting list for key $key: $e');
      return defaultValue;
    }
  }

  /// Safely gets a nested Map from a Map
  static Map<String, dynamic> safeGetMap(
    Map<String, dynamic> map,
    String key, [
    Map<String, dynamic>? defaultValue,
  ]) {
    return safeGet<Map<String, dynamic>>(map, key, defaultValue ?? {}) ?? {};
  }

  /// Merges two JSON objects (Maps)
  static Map<String, dynamic> mergeJson(
    Map<String, dynamic> json1,
    Map<String, dynamic> json2,
  ) {
    final result = Map<String, dynamic>.from(json1);
    json2.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          result[key] is Map<String, dynamic>) {
        result[key] = mergeJson(result[key] as Map<String, dynamic>, value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// Removes null values from a Map
  static Map<String, dynamic> removeNullValues(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value != null) {
        if (value is Map<String, dynamic>) {
          result[key] = removeNullValues(value);
        } else if (value is List) {
          result[key] = value.where((item) => item != null).toList();
        } else {
          result[key] = value;
        }
      }
    });
    return result;
  }

  /// Flattens a nested Map into a single level Map with dot notation keys
  static Map<String, dynamic> flatten(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, dynamic>{};

    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        result.addAll(flatten(value, newKey));
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }

  /// Gets a nested value using dot notation (e.g., 'user.profile.name')
  static dynamic getNestedValue(Map<String, dynamic> map, String path) {
    final keys = path.split('.');
    dynamic current = map;

    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current;
  }

  /// Sets a nested value using dot notation
  static void setNestedValue(
    Map<String, dynamic> map,
    String path,
    dynamic value,
  ) {
    final keys = path.split('.');
    Map<String, dynamic> current = map;

    for (int i = 0; i < keys.length - 1; i++) {
      final key = keys[i];
      if (!current.containsKey(key) || current[key] is! Map<String, dynamic>) {
        current[key] = <String, dynamic>{};
      }
      current = current[key] as Map<String, dynamic>;
    }

    current[keys.last] = value;
  }

  /// Converts query parameters to a Map
  static Map<String, dynamic> queryToMap(String query) {
    final result = <String, dynamic>{};

    if (query.isEmpty) return result;

    final pairs = query.split('&');
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        final key = Uri.decodeComponent(parts[0]);
        final value = Uri.decodeComponent(parts[1]);
        result[key] = value;
      }
    }

    return result;
  }

  /// Converts a Map to query parameters string
  static String mapToQuery(Map<String, dynamic> map) {
    final pairs = <String>[];

    map.forEach((key, value) {
      if (value != null) {
        final encodedKey = Uri.encodeComponent(key);
        final encodedValue = Uri.encodeComponent(value.toString());
        pairs.add('$encodedKey=$encodedValue');
      }
    });

    return pairs.join('&');
  }

  /// Deep clones a JSON object
  static dynamic deepClone(dynamic jsonObject) {
    if (jsonObject == null) return null;

    try {
      final jsonString = json.encode(jsonObject);
      return json.decode(jsonString);
    } catch (e) {
      developer.log('Error deep cloning JSON object: $e');
      return jsonObject;
    }
  }

  /// Compares two JSON objects for equality
  static bool isEqual(dynamic json1, dynamic json2) {
    try {
      final string1 = json.encode(json1);
      final string2 = json.encode(json2);
      return string1 == string2;
    } catch (e) {
      return false;
    }
  }

  /// Validates required fields in a JSON object
  static Map<String, String> validateRequiredFields(
    Map<String, dynamic> data,
    List<String> requiredFields,
  ) {
    final errors = <String, String>{};

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        errors[field] = 'Field $field is required';
      } else if (data[field] is String &&
          (data[field] as String).trim().isEmpty) {
        errors[field] = 'Field $field cannot be empty';
      }
    }

    return errors;
  }

  /// Converts JSON string to object using a factory function
  static T? jsonToObject<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final map = jsonToMap(jsonString);
      if (map.isEmpty) return null;
      return fromJson(map);
    } catch (e) {
      developer.log('Error converting JSON to object: $e');
      return null;
    }
  }

  /// Converts Map to object using a factory function
  static T? mapToObject<T>(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      return fromJson(map);
    } catch (e) {
      developer.log('Error converting Map to object: $e');
      return null;
    }
  }

  /// Converts object to JSON string using a toJson function
  static String objectToJson<T>(
    T object,
    Map<String, dynamic> Function(T) toJson,
  ) {
    try {
      final map = toJson(object);
      return mapToJson(map);
    } catch (e) {
      developer.log('Error converting object to JSON: $e');
      return '{}';
    }
  }

  /// Converts object to Map using a toJson function
  static Map<String, dynamic> objectToMap<T>(
    T object,
    Map<String, dynamic> Function(T) toJson,
  ) {
    try {
      return toJson(object);
    } catch (e) {
      developer.log('Error converting object to Map: $e');
      return {};
    }
  }

  /// Converts JSON array string to List of objects
  static List<T> jsonArrayToObjectList<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final list = jsonToList(jsonString);
      return list
          .where((item) => item is Map<String, dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Error converting JSON array to object list: $e');
      return [];
    }
  }

  /// Converts List of Maps to List of objects
  static List<T> mapListToObjectList<T>(
    List<Map<String, dynamic>> mapList,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      return mapList.map((map) => fromJson(map)).toList();
    } catch (e) {
      developer.log('Error converting Map list to object list: $e');
      return [];
    }
  }

  /// Converts List of objects to JSON array string
  static String objectListToJson<T>(
    List<T> objects,
    Map<String, dynamic> Function(T) toJson,
  ) {
    try {
      final mapList = objects.map((obj) => toJson(obj)).toList();
      return listToJson(mapList);
    } catch (e) {
      developer.log('Error converting object list to JSON: $e');
      return '[]';
    }
  }

  /// Converts List of objects to List of Maps
  static List<Map<String, dynamic>> objectListToMapList<T>(
    List<T> objects,
    Map<String, dynamic> Function(T) toJson,
  ) {
    try {
      return objects.map((obj) => toJson(obj)).toList();
    } catch (e) {
      developer.log('Error converting object list to Map list: $e');
      return [];
    }
  }

  /// Safely converts JSON to object with null safety
  static T? safeJsonToObject<T>(
    String? jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (jsonString == null || jsonString.trim().isEmpty) return null;
    return jsonToObject(jsonString, fromJson);
  }

  /// Safely converts object to JSON with null safety
  static String? safeObjectToJson<T>(
    T? object,
    Map<String, dynamic> Function(T) toJson,
  ) {
    if (object == null) return null;
    return objectToJson(object, toJson);
  }

  /// Converts a Map to a more readable string representation
  static String mapToReadableString(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    _mapToStringRecursive(map, buffer, 0);
    return buffer.toString();
  }

  static void _mapToStringRecursive(
    Map<String, dynamic> map,
    StringBuffer buffer,
    int indent,
  ) {
    final indentString = '  ' * indent;

    map.forEach((key, value) {
      buffer.write('$indentString$key: ');

      if (value is Map<String, dynamic>) {
        buffer.writeln();
        _mapToStringRecursive(value, buffer, indent + 1);
      } else if (value is List) {
        buffer.writeln('[${value.join(', ')}]');
      } else {
        buffer.writeln(value.toString());
      }
    });
  }

  // ==================== FILE JSON OPERATIONS ====================

  /// Reads JSON from assets folder
  static Future<Map<String, dynamic>> readJsonFromAssets(
    String assetPath,
  ) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return jsonToMap(jsonString);
    } catch (e) {
      developer.log('Error reading JSON from assets: $e');
      return {};
    }
  }

  /// Reads JSON array from assets folder
  static Future<List<dynamic>> readJsonArrayFromAssets(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return jsonToList(jsonString);
    } catch (e) {
      developer.log('Error reading JSON array from assets: $e');
      return [];
    }
  }

  /// Reads JSON from local file
  static Future<Map<String, dynamic>> readJsonFromFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        return jsonToMap(jsonString);
      }
      return {};
    } catch (e) {
      developer.log('Error reading JSON from file: $e');
      return {};
    }
  }

  /// Writes JSON to local file
  static Future<bool> writeJsonToFile(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    try {
      final File file = File(filePath);
      final String jsonString = prettyPrint(data);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      developer.log('Error writing JSON to file: $e');
      return false;
    }
  }

  /// Reads JSON from documents directory
  static Future<Map<String, dynamic>> readJsonFromDocuments(
    String fileName,
  ) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      return await readJsonFromFile(filePath);
    } catch (e) {
      developer.log('Error reading JSON from documents: $e');
      return {};
    }
  }

  /// Writes JSON to documents directory
  static Future<bool> writeJsonToDocuments(
    Map<String, dynamic> data,
    String fileName,
  ) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      return await writeJsonToFile(data, filePath);
    } catch (e) {
      developer.log('Error writing JSON to documents: $e');
      return false;
    }
  }

  /// Reads JSON from cache directory
  static Future<Map<String, dynamic>> readJsonFromCache(String fileName) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      return await readJsonFromFile(filePath);
    } catch (e) {
      developer.log('Error reading JSON from cache: $e');
      return {};
    }
  }

  /// Writes JSON to cache directory
  static Future<bool> writeJsonToCache(
    Map<String, dynamic> data,
    String fileName,
  ) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      return await writeJsonToFile(data, filePath);
    } catch (e) {
      developer.log('Error writing JSON to cache: $e');
      return false;
    }
  }

  /// Checks if JSON file exists
  static Future<bool> jsonFileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      developer.log('Error checking if JSON file exists: $e');
      return false;
    }
  }

  /// Deletes JSON file
  static Future<bool> deleteJsonFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error deleting JSON file: $e');
      return false;
    }
  }

  /// Gets the full path for a file in documents directory
  static Future<String> getDocumentsFilePath(String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$fileName';
    } catch (e) {
      developer.log('Error getting documents file path: $e');
      return '';
    }
  }

  /// Gets the full path for a file in cache directory
  static Future<String> getCacheFilePath(String fileName) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      return '${directory.path}/$fileName';
    } catch (e) {
      developer.log('Error getting cache file path: $e');
      return '';
    }
  }

  /// Reads and converts JSON file to object
  static Future<T?> readObjectFromFile<T>(
    String filePath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final Map<String, dynamic> data = await readJsonFromFile(filePath);
      if (data.isNotEmpty) {
        return fromJson(data);
      }
      return null;
    } catch (e) {
      developer.log('Error reading object from file: $e');
      return null;
    }
  }

  /// Writes object to JSON file
  static Future<bool> writeObjectToFile<T>(
    T object,
    String filePath,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final Map<String, dynamic> data = toJson(object);
      return await writeJsonToFile(data, filePath);
    } catch (e) {
      developer.log('Error writing object to file: $e');
      return false;
    }
  }

  /// Reads JSON array from file and converts to object list
  static Future<List<T>> readObjectListFromFile<T>(
    String filePath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        return jsonArrayToObjectList(jsonString, fromJson);
      }
      return [];
    } catch (e) {
      developer.log('Error reading object list from file: $e');
      return [];
    }
  }

  /// Writes object list to JSON array file
  static Future<bool> writeObjectListToFile<T>(
    List<T> objects,
    String filePath,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final String jsonString = objectListToJson(objects, toJson);
      final File file = File(filePath);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      developer.log('Error writing object list to file: $e');
      return false;
    }
  }

  /// Appends data to existing JSON file (merges with existing data)
  static Future<bool> appendToJsonFile(
    String filePath,
    Map<String, dynamic> newData,
  ) async {
    try {
      Map<String, dynamic> existingData = {};

      // Read existing data if file exists
      if (await jsonFileExists(filePath)) {
        existingData = await readJsonFromFile(filePath);
      }

      // Merge data
      final Map<String, dynamic> mergedData = mergeJson(existingData, newData);

      // Write back to file
      return await writeJsonToFile(mergedData, filePath);
    } catch (e) {
      developer.log('Error appending to JSON file: $e');
      return false;
    }
  }

  /// Backs up JSON file
  static Future<bool> backupJsonFile(String filePath, String backupPath) async {
    try {
      final File sourceFile = File(filePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(backupPath);
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error backing up JSON file: $e');
      return false;
    }
  }
}
