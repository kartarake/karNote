import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:karnote/pages/home.dart';

void main() {
  runApp(const MyApp());
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
  bool isSidebarOpen = true; // Sidebar visibility state

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomTitleBar(onMenuPressed: toggleSidebar), // Pass function to title bar
      body: WindowBorder(
        color: Colors.transparent,
        child: Row(
          children: [
            // Sidebar with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSidebarOpen ? 250 : 0, // Expands & collapses
              child: isSidebarOpen ? const LeftSide() : null, // Efficient hiding
            ),
            // Main content (Unchanged)
            const Expanded(child: RightSide()),
          ],
        ),
      ),
    );
  }
}

/// **Custom Title Bar**
class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const CustomTitleBar({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: MoveWindow(
        child: Container(
          height: 40,
          width: double.infinity,
          color: Colors.transparent,
          child: Row(
            children: [
              LeftSideIcons(onMenuPressed: onMenuPressed),
              const Spacer(),
              const WindowButtons(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

/// **Left Side Icons (With Sidebar Toggle)**
class LeftSideIcons extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const LeftSideIcons({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _iconButton('assets/icons/tabler--menu-2.svg', onMenuPressed),
        _iconButton('assets/icons/tabler--folder-open.svg', () {}),
        _iconButton('assets/icons/tabler--search.svg', () {}),
      ],
    );
  }

  /// **Creates Icon Buttons**
  static Widget _iconButton(String assetPath, VoidCallback onTap) {
    return IconButton(
      icon: SvgPicture.asset(
        assetPath,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
      ),
      onPressed: onTap,
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
