import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'dart:io';
import 'package:karnote/main.dart';
import 'package:provider/provider.dart';
import 'package:karnote/algos/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});

  @override
  Widget build(BuildContext context) {
    FileListHolder fileHolder = Provider.of<FileListHolder>(context);

    // Add a listener to rebuild the widget when the current file is renamed
    fileHolder.currentFile.addListener(() {
      // Trigger a rebuild
      (context as Element).markNeedsBuild();
    });

    Widget buildFileListHeader() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/tabler--file.svg', // Ensure this path is correct
            height: 16,
            colorFilter: const ColorFilter.mode(Color(0xff767e7d), BlendMode.srcIn),
          ),

          SizedBox(width: 8),

          const Text(
            "Files",
            style: TextStyle(
              fontFamily: "FiraCode",
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xff767e7d),
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
                  onTap: () {
                    fileHolder.setCurrentFile(file);
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color(isSelected ? 0xff505659 : 0xff434a4e),
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
        color: const Color(0xff353e43),
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
        Text(
          file.path.split(Platform.pathSeparator).last,
          style: TextStyle(
            fontFamily: "FiraCode",
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xff818e8a),
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
              Color(0xff818e8a), BlendMode.srcIn),
          ),
        )
      ],
    );
  }
}


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
        print(fileListHolder.files);
        print(fileListHolder.currentFile.value);
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
              onPressed: () {print("Open File");},
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

class RightSide extends StatefulWidget {
  const RightSide({super.key});
  @override
  _RightSideState createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  CodeController? _codeController;
  late ScrollController _scrollController;
  FileListHolder? _fileHolder;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(language: dart);
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
      // Update the code editor with the current file's content.
      _updateEditorWithCurrentFile();
    }
  }

  /// Called when the code editor's text changes.
  /// Saves the current text in our cache, keyed by the file path.
  void _onCodeChanged() {
    Map<String, String> unsavedContents = _fileHolder!.unsavedContents;
    final currentFile = _fileHolder?.currentFile.value;
    if (currentFile != null) {
      unsavedContents[currentFile.path] = _codeController!.text;
    }
  }

  /// Called when the current file changes.
  /// Loads the content from the cache (if available) or from disk.
  void _onFileChanged() {
    _updateEditorWithCurrentFile();
  }

  /// Updates the code editor's text based on the current file.
  void _updateEditorWithCurrentFile() {
    Map<String, String> unsavedContents = _fileHolder!.unsavedContents;
    final currentFile = _fileHolder?.currentFile.value;
    if (currentFile != null) {
      // Use cached content if available.
      if (unsavedContents.containsKey(currentFile.path)) {
        _codeController!.text = unsavedContents[currentFile.path]!;
      } else {
        try {
          _codeController!.text = currentFile.readAsStringSync();
        } catch (e) {
          _codeController!.text = "";
        }
      }
    } else {
      _codeController!.text = "";
    }
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
                color: Color(0xff1b1f22),
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
  /// Notice that we removed the assignment to _codeController!.text here,
  /// since the text is now updated in the file change listener.
  Widget buildCodeEditor(FileListHolder fileListHolder) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xff15181a), // Editor background
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
        Text(
          fileListHolder.currentFile.value?.path.split(Platform.pathSeparator).last ??
              "Untitled",
          style: const TextStyle(
            fontFamily: "FiraCode",
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xff818e8a),
          ),
        ),
        buildRenameButton(),
        const Spacer(),
        buildSaveButton(fileListHolder),
        //buildVersionHistoryButton(),
        buildDeleteButton(fileListHolder),
      ],
    );
  }

  Widget buildRenameButton() {
    return IconButton(
      onPressed: () {
        showRenameFileDialog(context).then((newName) {
          if (newName != null) {
            _fileHolder!.renameCurrentFile(newName);
            print(_fileHolder!.currentFile.value);
            print(_fileHolder!.files);
          }
        });
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--pencil.svg', // Ensure this path is correct
        height: 16,
        colorFilter:
            const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
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
                // Close the dialog and return null if canceled.
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog and return the entered file name.
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
        colorFilter:
            const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
    );
  }

  /// Displays a confirmation dialog asking the user if they want to delete the file.
  /// 
  /// Returns a [Future<bool>] that resolves to `true` if the user confirms deletion,
  /// or `false` if the user cancels.
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return (await showDialog<bool>(
      context: context,
      barrierDismissible: false, // The user must tap a button.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete the current file?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels.
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms deletion.
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    )) ?? false; // Return false if the dialog is dismissed.
  }

  Widget buildSaveButton(FileListHolder fileListHolder) {
    return IconButton(
      onPressed: () {
        saveFile(fileListHolder.currentFile.value?.path ?? "", _codeController!.text);
      },
      icon: SvgPicture.asset(
        'assets/icons/tabler--device-floppy.svg', // Ensure this path is correct
        height: 16,
        colorFilter:
            const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
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
        colorFilter:
            const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
    );
  }
}
