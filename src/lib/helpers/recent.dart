import "package:karnote/helpers/file.dart";

String recentFilePath = "recent.json";

Future<Map<String,dynamic>> loadRecentFiles() async {
  if (!await fileExists(recentFilePath)) {
    await saveJSON(recentFilePath, {"context":"data file for karNOTE to store few recent files","data":[]});
  }
  Map<String,dynamic> dataOnFile = await readJSON(recentFilePath);
  return dataOnFile;
}

Future<void> saveRecentFiles(Map<String,dynamic> data) async {
  await saveJSON(recentFilePath, data);
}

Future<void> addRecentFile(String path) async {
  Map<String,dynamic> data = await loadRecentFiles();
  List<dynamic> pathList = data["data"];
  if (pathList.length >= 5) {
    pathList.removeLast();
  }
  pathList.insert(0, path);
  await saveRecentFiles(data);
}