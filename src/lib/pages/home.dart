// Main Dependencies
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

// Code Editor Dependencies
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/all.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

// Local Imports
import 'package:karnote/main.dart';
import 'package:karnote/helpers/file.dart';

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

    Widget buildFileList() {
      return SizedBox(
        height: 500,
        child: ValueListenableBuilder<File?>(
          valueListenable: fileHolder.currentFile, 
          builder: (context, currentFile, _) {
            return ListView.separated(
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
            buildFileList()
          ],
        ),
      ),
    );
  }

  Row buildFileListRow(File file, FileListHolder fileHolder) {
    return Row(
      children: [
        Expanded( // Wrap with Expanded
          child: Text(
            file.path.split(Platform.pathSeparator).last,
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xffc1c2e5),
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
            colorFilter: const ColorFilter.mode(
              Color(0xffc1c2e5), BlendMode.srcIn),
          ),
        )
      ],
    );
  }
}

// The welcome screen on start of the app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FileListHolder fileListHolder = Provider.of<FileListHolder>(context);

    void onNewFilePressed () async {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        File newFile = File(path.join(selectedDirectory, "Untitled.txt"));
        saveFile(newFile.path, "");
        fileListHolder.addFile(newFile);
        fileListHolder.setCurrentFile(newFile);
      }
    }

    void onOpenFolderPressed () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
        fileListHolder.addFile(file);
        fileListHolder.setCurrentFile(file);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 140),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 70),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xff818e8a), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to karNOTE",
              style: TextStyle(
                fontFamily: "FiraCode",
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xff818e8a),
              ),
            ),
            SizedBox(height: 40),
            TextButton(
              onPressed: () {onNewFilePressed();},
              child: const Text(
                "> New File",
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  color: Color(0xff818e8a),
                ),
              ),
            ),
            TextButton(
              onPressed: () {onOpenFolderPressed();},
              child: const Text(
                "> Open File",
                style: TextStyle(
                  fontFamily: "FiraCode",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  color: Color(0xff818e8a),
                ),
              ),
            ),
          ],
        )
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
    _autoSaveTimer = Timer(autoSaveDelay, () {
      final filePath = _fileHolder!.currentFile.value?.path ?? "";
      if (filePath.isNotEmpty) {
        safeSaveFile(filePath, _codeController!.text);
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
          height: 488, // Fixed max height for the code editor
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
        buildSaveButton(fileListHolder),
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

  Widget buildSaveButton(FileListHolder fileListHolder) {
    return IconButton(
      onPressed: () {
        saveFile(fileListHolder.currentFile.value?.path ?? "", _codeController!.text);
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--device-floppy.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff808080), BlendMode.srcIn),
      ),
    );
  }

  Widget buildVersionHistoryButton() {
    return IconButton(
      onPressed: () {
        print("Version History called");
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--clock.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff808080), BlendMode.srcIn),
      ),
    );
  }
}
