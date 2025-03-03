import 'package:karnote/helpers/file.dart';
import 'dart:io';

String replaceExtension(String filePath, String newExtension) {
  final parts = filePath.split('.');
  parts.removeLast();
  return '${parts.join('.')}$newExtension';
}

Future<bool> fileExists(String filePath) async {
  return await File(filePath).exists();
}

Future<bool> newVersionsFile(String forFilePath) async {
  final String versionsFilePath = replaceExtension(forFilePath, '.versions');
  await saveJSON(versionsFilePath, {});
  return true;
}

void saveVersion(String filePath, Map<String,dynamic> versionData) async {
  final String versionsFilePath = replaceExtension(filePath, '.versions');
  if (!await fileExists(versionsFilePath)) {
    await newVersionsFile(filePath);
  }
  final Map<String,dynamic> versions = await readJSON(versionsFilePath);
  versions[DateTime.now().toIso8601String()] = versionData;
  await saveJSON(versionsFilePath, versions);
}

String isoToHuman(String isoString) {
  final DateTime dateTime = DateTime.parse(isoString);
  return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
}

Future<Map<String, dynamic>> getVersions(String filePath) async {
  final String versionsFilePath = replaceExtension(filePath, '.versions');
  final Map<String,dynamic> versions = await readJSON(versionsFilePath);
  return versions;
}