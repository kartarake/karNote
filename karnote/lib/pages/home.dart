import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'dart:io';
import 'package:karnote/main.dart';
import 'package:provider/provider.dart';

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
                    child: Row(
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
                          },
                          icon: SvgPicture.asset(
                            'assets\\icons\\tabler--x.svg',
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              Color(0xff818e8a), BlendMode.srcIn),
                          ),
                        )
                      ],
                    ),
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
}


class RightSide extends StatefulWidget{
  const RightSide({super.key});
  @override
  _RightSideState createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  CodeController? _codeController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      language: dart,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
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
                color: Color(0xff1b1f22)
              ),
              child: Column(
                children: [
                  buildFileBar(fileListHolder),
                  const SizedBox(height: 10),
                  buildCodeEditor(fileListHolder)
                ]
              ),
            ),
          )
        ),
      ],
    );
  }

  Widget buildCodeEditor(FileListHolder fileListHolder) {
    _codeController!.text = fileListHolder.currentFile.value?.readAsStringSync() ?? "";
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
            thumbColor: Color(0xff767e7d),
            thickness: 8,
            radius: Radius.circular(10),
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

  Widget buildFileBar(FileListHolder fileListHolder) {
    return Row(
      children: [
        Text(
          fileListHolder.currentFile.value?.path.split(Platform.pathSeparator).last ?? "Untitled",
          style: TextStyle(
            fontFamily: "FiraCode",
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xff818e8a)
          ),
        ),
        buildRenameButton(),
        const Spacer(),
        buildSaveButton(),
        buildVersionHistoryButton(),
        buildDeleteButton()
      ],
    );
  }

  Widget buildRenameButton() {
    return IconButton(
      onPressed: () {print("Rename called");},
      icon: SvgPicture.asset(
        'assets/icons/tabler--pencil.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
    );
  }

  Widget buildDeleteButton() {
    return IconButton(
      onPressed: () {print("Delete called");},
      icon: SvgPicture.asset(
        'assets/icons/tabler--trash.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
    );
  }

  Widget buildSaveButton() {
    return IconButton(
      onPressed: () {print("Save called");},
      icon: SvgPicture.asset(
        'assets/icons/tabler--device-floppy.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
    );
  }

  Widget buildVersionHistoryButton() {
    return IconButton(
      onPressed: () {print("Version History called");},
      icon: SvgPicture.asset(
        'assets/icons/tabler--clock.svg', // Ensure this path is correct
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
    );
  }
}

