import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'package:karnote/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => FileListHolder(),
      child: MyApp()
    )
  );

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 720);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "karNOTE";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'karNOTE',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xff1b1f22),
      ),
      home: const AppLayout(),
    );
  }
}

/// **Main App Layout**
class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  _AppLayoutState createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final ValueNotifier<bool> isSidebarOpen = ValueNotifier(true);
  final FileListHolder fileHolder = FileListHolder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomTitleBar(onMenuPressed: () {
        isSidebarOpen.value = !isSidebarOpen.value;
      }),
      body: WindowBorder(
        color: Colors.transparent,
        child: Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isSidebarOpen,
              builder: (context, isOpen, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isOpen ? 250 : 0,
                  child: Visibility(visible: isOpen, child: const LeftSide()),
                );
              },
            ),
            const Expanded(child: RightSide()),
          ],
        ),
      ),
    );
  }
}


class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const CustomTitleBar({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        height: 40,
        width: double.infinity,
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            LeftSideIcons(onMenuPressed: onMenuPressed),
            Expanded(child: MoveWindow()),
            const WindowButtons(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}


class LeftSideIcons extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const LeftSideIcons({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final FileListHolder fileHolder = Provider.of<FileListHolder>(context);

    void onFolderOpenPressed () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
        fileHolder.addFile(file);
        print(fileHolder.files);
      }
    }

    return Row(
      children: [
        _iconButton('assets/icons/tabler--menu-2.svg', onMenuPressed, "Side Bar"),
        _iconButton('assets/icons/tabler--folder-open.svg', onFolderOpenPressed, "Open File"),
        _iconButton('assets/icons/tabler--search.svg', () {}, "Search"),
      ],
    );
  }


  /// **Creates Icon Buttons**
  static Widget _iconButton(String assetPath, VoidCallback onTap, String toolTip) {
    return IconButton(
      icon: SvgPicture.asset(
        assetPath,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
      onPressed: onTap,
      tooltip: toolTip,
    );
  }
}

/// **Window Control Buttons**
class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

/// **Button Colors**
final buttonColors = WindowButtonColors(
  iconNormal: const Color(0xFF767e7d),
  mouseOver: const Color(0xFF767e7d),
  mouseDown: const Color(0xFFffffff),
  iconMouseOver: const Color(0xFF1b1f22),
  iconMouseDown: const Color(0xFFFFFFFF),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color(0xFF767e7d),
  iconMouseOver: Colors.white,
);


class FileListHolder extends ChangeNotifier {
  final List<File> _files = [];
  ValueNotifier<File?> currentFile = ValueNotifier<File?>(null);

  List<File> get files => _files;
  File get current => currentFile.value!;

  void setCurrentFile(File file) {
    currentFile.value = file;
    notifyListeners();
  }

  void addFile(File file) {
    _files.add(file);
    notifyListeners();
  }

  void removeFile(File file) {
    _files.remove(file);
    notifyListeners();
  }
}