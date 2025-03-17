// Main Dependencies
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

// Code Editor Dependencies
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/all.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

// Local Imports
import 'package:karnote/main.dart';
import 'package:karnote/helpers/file.dart';
import 'package:karnote/helpers/versions.dart';
import 'package:karnote/helpers/recent.dart';

// The Left side sidebar of the app.
class LeftSide extends StatelessWidget {
  const LeftSide({super.key});

  @override
  Widget build(BuildContext context) {
    FileListHolder fileHolder = Provider.of<FileListHolder>(context);

    Widget buildFileListHeader() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/tabler--file.svg', // Ensure this path is correct
            height: 16,
            colorFilter: const ColorFilter.mode(Color(0xffc1c2e5), BlendMode.srcIn),
          ),
          SizedBox(width: 8),
          const Expanded( // Wrap with Expanded
            child: Text(
              "Files",
              style: TextStyle(
                fontFamily: "FiraCode",
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xffc1c2e5),
              ),
            ),
          ),
        ],
      );
    }

    Widget buildSideBarToolbox() {
      Widget NewFileButton = TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(color: Color(0xff4e3fbd)),
          ),
          backgroundColor: Color.fromRGBO(78, 63, 189, 0.2)
        ),

        onPressed: () async {
          FileListHolder fileListHolder = Provider.of<FileListHolder>(context, listen: false);
          String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
          if (selectedDirectory != null) {
            File newFile = File(path.join(selectedDirectory, "Untitled.txt"));
            saveFile(newFile.path, "");
            fileListHolder.addFile(newFile);
            fileListHolder.setCurrentFile(newFile);
            await addRecentFile(newFile.path);
          }
        },
        child: Container(
          width: 120,
          height: 26,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/tabler--file-plus.svg',
                height: 16,
                colorFilter: const ColorFilter.mode(Color(0xffc1c2e5), BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                "New File",
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xffc1c2e5),
                ),
              ),
            ],
          ),
        )
      );

      return Container(
        width: 200,
        height: 55,
        decoration: BoxDecoration(
          color: Color.fromRGBO(78, 63, 189, 0.15),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            NewFileButton,
            const Spacer(),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/github-mark.svg',
                height: 16,
                colorFilter: const ColorFilter.mode(Color(0xffc1c2e5), BlendMode.srcIn),
              ),
              onPressed: () async {
                Uri url = Uri.parse('https://github.com/kartarake/karNote');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            const SizedBox(width: 5),
          ]
        )
      );
    }

    Widget buildFileList() {
      return SizedBox(
        height: 477,
        child: ValueListenableBuilder<File?>(
          valueListenable: fileHolder.currentFile, 
          builder: (context, currentFile, _) {
            return (fileHolder.files.isNotEmpty)? ListView.separated(
              itemCount: fileHolder.files.length,
              itemBuilder: (context, index) {
                File file = fileHolder.files[index];
                bool isSelected = file.path == currentFile?.path;
                return InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () {
                    fileHolder.setCurrentFile(file);
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected? Color.fromRGBO(26, 26, 26, 0.2) : Color.fromRGBO(26, 26, 26, 0.4),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: buildFileListRow(file, fileHolder),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 10),
            ) : Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(26, 26, 26, 0.2),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      "No File is opened",
                      style: TextStyle(
                        fontFamily: "FiraCode",
                        fontSize: 12,
                        color: Color(0xffc1c2e5),
                      ),
                    ),
                  )
                ),
              ],
            );
          },
        ),
      );
    }

    return SizedBox(
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff4d4d4d), Color(0x004e3fbd)]
          )
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 82),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFileListHeader(),
            buildFileList(),
            buildSideBarToolbox()
          ],
        ),
      ),
    );
  }

  Row buildFileListRow(File file, FileListHolder fileHolder) {
    bool isSelected = file.path == fileHolder.currentFile.value?.path;
    return Row(
      children: [
        Expanded( // Wrap with Expanded
          child: Text(
            file.path.split(Platform.pathSeparator).last,
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected? Color(0xffc1c2e5) : Color(0xff808080),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            fileHolder.removeFile(file);
            if (fileHolder.currentFile.value == file && fileHolder.files.isNotEmpty) {
              fileHolder.setCurrentFile(fileHolder.files.first);
            }
          },
          icon: SvgPicture.asset(
            'assets\\icons\\tabler--x.svg',
            height: 16,
            colorFilter: ColorFilter.mode(
              isSelected? Color(0xffc1c2e5) : Color(0xff808080),
              BlendMode.srcIn),
          ),
        )
      ],
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<Widget> recentListFuture;

  @override
  void initState() {
    super.initState();
    recentListFuture = buildRecentList();
  }

  @override
  Widget build(BuildContext context) {
    FileListHolder fileListHolder = Provider.of<FileListHolder>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildGreetingWidget(),
          const Spacer(),
          buildWorkActions(fileListHolder),
          const SizedBox(height: 30),
          FutureBuilder<Widget>(
            future: recentListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Loading indicator
              } else if (snapshot.hasError) {
                return Text(
                  "Error loading recent files",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "FiraCode",
                    color: Color(0xff8385cb),
                  ),
                );
              } else {
                return snapshot.data ?? Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildGreetingWidget() {
    return Row(
      children: [
        SizedBox(width: 8),
        SvgPicture.asset(
          "assets/illustrations/abstact.svg",
          height: 162,
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Text(
              "Welcome,",
              style: TextStyle(
                fontFamily: "FiraCode",
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xffffffff),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 35),
                Text(
                  "Boss",
                  style: TextStyle(
                    fontFamily: "FiraCode",
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff4e3fbd),
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/tabler--pencil.svg",
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    Color(0xff4e3fbd),
                    BlendMode.srcIn,
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  Widget buildWorkActions(FileListHolder fileListHolder) {
    void onNewFilePressed() async {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        File newFile = File(path.join(selectedDirectory, "Untitled.txt"));
        saveFile(newFile.path, "");
        fileListHolder.addFile(newFile);
        fileListHolder.setCurrentFile(newFile);
        await addRecentFile(newFile.path);
        recentListFuture = buildRecentList();
      }
    }

    void onOpenFolderPressed() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
        fileListHolder.addFile(file);
        fileListHolder.setCurrentFile(file);
        await addRecentFile(file.path);
        recentListFuture = buildRecentList();
      }
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Let's get some work done",
            style: TextStyle(
              fontSize: 12,
              fontFamily: "FiraCode",
              color: Color(0xffffffff),
            ),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: onNewFilePressed,
              child: Text(
                "New File",
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  color: Color(0xff8385cb),
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenFolderPressed,
              child: Text(
                "Open File",
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  color: Color(0xff8385cb),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Future<Widget> buildRecentList() async {
    Map<String, dynamic> fileData = await loadRecentFiles();
    List<dynamic> filePathList = fileData["data"];
    List<Widget> fileWidgets = [];

    fileWidgets.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Recent",
          style: TextStyle(
            fontSize: 12,
            fontFamily: "FiraCode",
            color: Color(0xffffffff),
          ),
        ),
      ),
    );

    if (filePathList.isEmpty) {
      fileWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No recent files",
            style: TextStyle(
              fontSize: 12,
              fontFamily: "FiraCode",
              color: Color(0xff8385cb),
            ),
          ),
        ),
      );
    } else {
      for (String path in filePathList) {
        fileWidgets.add(buildRecentFile(File(path)));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fileWidgets,
    );
  }

  Widget buildRecentFile(File file) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )
      ),
      onPressed: () async {
        FileListHolder fileListHolder = Provider.of<FileListHolder>(context, listen: false);
        fileListHolder.addFile(file);
        fileListHolder.setCurrentFile(file);
        await addRecentFile(file.path);
        recentListFuture = buildRecentList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/icons/tabler--file.svg",
            height: 16,
            colorFilter: ColorFilter.mode(
              Color(0xff8385cb),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            file.path.split(Platform.pathSeparator).last,
            style: TextStyle(
              fontSize: 12,
              fontFamily: "FiraCode",
              color: Color(0xff8385cb),
            ),
          ),
        ],
      ),
    );
  }
}


// The code editor screen.
class RightSide extends StatefulWidget {
  const RightSide({super.key});
  @override
  _RightSideState createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  CodeController? _codeController;
  late ScrollController _scrollController;
  FileListHolder? _fileHolder;
  Timer? _autoSaveTimer;
  static const Duration autoSaveDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    // Initialize CodeController with default language (Dart)
    _codeController = CodeController(language: allLanguages['.txt']);
    _scrollController = ScrollController();

    // Listen for changes in the code editor and update our cache.
    _codeController!.addListener(_onCodeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtain the FileListHolder from Provider.
    final newHolder = Provider.of<FileListHolder>(context);
    // If the FileListHolder instance changed, update our listener.
    if (_fileHolder != newHolder) {
      _fileHolder?.currentFile.removeListener(_onFileChanged);
      _fileHolder = newHolder;
      _fileHolder!.currentFile.addListener(_onFileChanged);
      // Update the code editor with the current file's content and language.
      _updateEditorWithCurrentFile();
    }
  }

  /// Called when the code editor's text changes.
  /// Saves the current text in our cache, keyed by the file path.
  void _onCodeChanged() {
    _autoSaveTimer?.cancel();
    if (_fileHolder!.isSaved) {
      _fileHolder!.switchSaveStatus();
    }
    _autoSaveTimer = Timer(autoSaveDelay, () {
      final filePath = _fileHolder!.currentFile.value?.path ?? "";
      if (filePath.isNotEmpty) {
        safeSaveFile(filePath, _codeController!.text);
        _fileHolder!.switchSaveStatus();
      }
    });
  }

  /// Called when the current file changes.
  /// Loads the content from the cache (if available) or from disk, and updates syntax highlighting.
  void _onFileChanged() {
    _updateEditorWithCurrentFile();
  }

  /// Updates the code editor's text and language based on the current file.
  void _updateEditorWithCurrentFile() async {
    final currentFile = _fileHolder?.currentFile.value;

    if (currentFile == null) {
      _codeController!.text = '';
      _codeController!.language = allLanguages['plaintext'];
      return;
    } else {
      _codeController!.text = await readFile(currentFile.path);
      _codeController!.language = _getLanguageForFile(currentFile.path);
    }
  }

  /// Determines the syntax highlighting language for a given file path.
  /// Returns a Mode for known extensions, or null for plain text.
  Mode? _getLanguageForFile(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    // Remove the leading dot:
    final fileExt = ext.isNotEmpty ? ext.substring(1) : '';

    // Mapping table for common file extensions to language keys.
  final extensionMapping = <String, String>{
     // Programming languages:
      'dart': 'dart',
      'py': 'python',
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'c': 'c',
      'h': 'cpp',
      'cpp': 'cpp',
      'cc': 'cpp',
      'cxx': 'cpp',
      'cs': 'csharp',
      'java': 'java',
      'rb': 'ruby',
      'php': 'php',
      'go': 'go',
      'rs': 'rust',
      'swift': 'swift',
      'kt': 'kotlin',
      'kts': 'kotlin',
      'scala': 'scala',
      'hs': 'haskell',
      'sql': 'sql',
      
      // Web & Markup:
      'html': 'xml',
      'htm': 'xml',
      'css': 'css',
      'xml': 'xml',

      // Data & Configuration:
      'json': 'json',
      'yml': 'yaml',
      'yaml': 'yaml',
      'tsv': 'csv',
      'ini': 'ini',
      'conf': 'ini',
      'cfg': 'ini',

      // Markup & Documentation:
      'md': 'markdown',
      'mdx': 'markdown',
      'rmd': 'markdown',
      'txt': 'plaintext',
      'tex': 'latex',
      'latex': 'latex',

      // Shell & Scripting:
      'sh': 'bash',
      'bash': 'bash',
      'zsh': 'bash',
      'bat': 'dos',
      'ps1': 'powershell',
      'pl': 'perl',
      'lua': 'lua',

      // Others:
      'r': 'r',
      'vb': 'vbnet',
      'vbs': 'vbnet',
      'cshtml': 'razor',
      'asp': 'asp',
      'aspx': 'asp',
      'jsp': 'jsp',
      'coffee': 'coffeescript',
      'json5': 'json',
      'lock': 'json',
    };

    final languageKey = extensionMapping[fileExt] ?? fileExt;

    return allLanguages[languageKey] ?? allLanguages['plaintext'];
  }


  @override
  void dispose() {
    _codeController!.removeListener(_onCodeChanged);
    _fileHolder?.currentFile.removeListener(_onFileChanged);
    _codeController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FileListHolder fileListHolder = Provider.of<FileListHolder>(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                children: [
                  buildFileBar(fileListHolder),
                  const SizedBox(height: 10),
                  buildCodeEditor(fileListHolder),
                  const SizedBox(height: 10),
                  saveStatus(fileListHolder)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget saveStatus(FileListHolder fileListHolder) {
    if (fileListHolder.isSaved) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.check,
            size: 12,
            color: const Color(0xff808080),
          ),
          SizedBox(width: 5),
          Text(
            "Saved",
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 12,
              color: const Color(0xff808080),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1,
              color: const Color(0xff808080),
            ),
          ),
          SizedBox(width: 5),
          Text(
            "Saving",
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 12,
              color: const Color(0xff808080),
            ),
          ),
        ],
      );
    }
  }

  /// The code editor widget.
  Widget buildCodeEditor(FileListHolder fileListHolder) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xff171717), // Editor background
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: SizedBox(
          height: 461, // Fixed max height for the code editor
          child: RawScrollbar(
            interactive: true,
            thumbColor: const Color(0xff767e7d),
            thickness: 8,
            radius: const Radius.circular(10),
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: CodeTheme(
                data: const CodeThemeData(styles: atomOneDarkTheme),
                child: CodeField(
                  controller: _codeController!,
                  lineNumbers: true,
                  expands: false,
                  background: Colors.transparent,
                  textStyle: const TextStyle(
                    fontFamily: "FiraCode",
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the file bar at the top of the editor.
  Widget buildFileBar(FileListHolder fileListHolder) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: buildFileName(fileListHolder),
              ),
              const SizedBox(width: 4),
              buildRenameButton(),
            ],
          ),
        ),
        buildVersionHistoryButton(),
        // buildSaveButton(fileListHolder),
        const SizedBox(width: 8),
        buildDeleteButton(fileListHolder),
      ],
    );
  }

  Text buildFileName(FileListHolder fileListHolder) {
    return Text(
      fileListHolder.currentFile.value?.path.split(Platform.pathSeparator).last ?? "Untitled",
      style: const TextStyle(
        fontFamily: "FiraCode",
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xff808080),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildRenameButton() {
    return IconButton(
      tooltip: "Rename File",
      onPressed: () {
        showRenameFileDialog(context).then((newName) {
          if (newName != null) {
            _fileHolder!.renameCurrentFile(newName);
          }
        });
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--pencil.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff808080), BlendMode.srcIn),
      ),
    );
  }

  Future<String?> showRenameFileDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Force the user to tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new file name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDeleteButton(FileListHolder fileListHolder) {
    return IconButton(
      tooltip: "Delete File",
      onPressed: () {
        showDeleteConfirmationDialog(context).then((confirmed) {
          if (confirmed) {
            _fileHolder!.removeFile(_fileHolder!.currentFile.value!);
            deleteFile(fileListHolder.currentFile.value!);
          }
        });
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--trash.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff808080), BlendMode.srcIn),
      ),
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return (await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete the current file?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    )) ?? false;
  }

  Widget buildVersionHistoryButton() {
    return IconButton(
      tooltip: "Version History",
      onPressed: () {
        showVersionControlDialog(context);
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--clock.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff808080), BlendMode.srcIn),
      ),
    );
  }

  Future<void> showVersionControlDialog(BuildContext context) async {
    Column structure = await buildVersionControlStructure();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        
        return AlertDialog(
          backgroundColor: const Color(0xff171717),
          title: const Text(
            'Version History',
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff808080),
            ),
          ),
          content: structure,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<Column> buildVersionControlStructure() async {
    final versions = await getVersions(_fileHolder!.currentFile.value!.path);
    List<String> keys = versions.keys.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        buildNewVersionButton(),
        const SizedBox(height: 10),
        buildVersionList(keys, versions)
      ]
    );
  }

  SizedBox buildVersionList(List<String> keys, Map<String, dynamic> versions) {
    return SizedBox(
      width: 400,
      height: 300,
      child: ListView.separated(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> version = versions[keys[index]];
          return ListTile(
            tileColor: Color(0x114e3fbd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hoverColor: Color(0x33ffffff),
            title: Text(
              version["title"],
              style: const TextStyle(
                fontFamily: "FiraCode",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xffc1c2e5),
              ),
            ),
            subtitle: Text(
              isoToHuman(keys[index]),
              style: const TextStyle(
                fontFamily: "FiraCode",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff808080),
              ),
            ),
            onTap: () {
              askToChangeVersion(context, version);
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 5),
      ),
    );
  }

  TextButton buildNewVersionButton () {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Color(0xff4e3fbd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        askForNewVersionDetails();
      },
      child: Row(
        children: [
          Text(
            "New Version",
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xffffffff),
            ),
          ),
          Spacer(),
          SvgPicture.asset(
            'assets\\icons\\tabler--device-floppy.svg',
            height: 16,
            colorFilter: const ColorFilter.mode(Color(0xffffffff), BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  void askForNewVersionDetails () {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New Version"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 1,
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> versionData = {
                  "title": titleController.text,
                  "desc": descriptionController.text,
                  "content": _codeController!.text,
                };
                saveVersion(_fileHolder!.currentFile.value!.path, versionData);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      } 
    );
  }


  Future<void> askToChangeVersion(BuildContext context, Map<String, dynamic> versionData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            versionData["title"],
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff808080),
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                versionData["desc"],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff808080),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                versionData["content"],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  color: Color(0xff808080),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xff171717),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                _codeController!.text = versionData["content"];
                Navigator.of(context).pop();
              },
              child: const Text("Load"),
            ),
          ],
        );
      },
    );
  }
}
