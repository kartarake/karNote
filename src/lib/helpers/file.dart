import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';


Future<String> readFile(String path) async {
  final file = File(path);
  return file
      .openRead()
      .transform(utf8.decoder)
      .join();
}


Future<void> saveFile(String path, String data) async {
  final file = File(path);
  await file.writeAsString(data, flush: true);
}


Future<void> safeSaveFile(String filePath, String content) async {
  const int maxRetries = 3;
  const Duration retryDelay = Duration(milliseconds: 200);

  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      final file = File(filePath);
      await file.writeAsString(content, mode: FileMode.write, flush: true);
      debugPrint('File saved successfully.');
      return; // Success
    } catch (e) {
      debugPrint('Attempt ${attempt + 1} failed to save file: $e');
      if (attempt < maxRetries - 1) {
        await Future.delayed(retryDelay);
      } else {
        rethrow;
      }
    }
  }
}


Future<Map<String, dynamic>> readJSON(String path) async {
  final contents = await readFile(path);
  return jsonDecode(contents) as Map<String, dynamic>;
}


Future<void> saveJSON(String path, Map<String, dynamic> jsonObject) async {
  final jsonString = jsonEncode(jsonObject);
  await saveFile(path, jsonString);
}


Future<void> deleteFile(File file) async {
  if (await file.exists()) {
    try {
      await file.delete();
    } catch (e) {
      throw Exception("Error deleting file ${file.path}: $e");
    }
  } else {
    throw Exception("File does not exist: ${file.path}");
  }
}