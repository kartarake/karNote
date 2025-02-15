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
      home: const AppLayout(),
    );
  }
}

/// **Main App Structure**
class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(),
      body: WindowBorder(
        color: Colors.transparent,
        child: const AppContent(),
      ),
    );
  }
}

/// **Optimized Custom Title Bar (Fixes Slow Buttons)**
class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        height: 40,
        color: Colors.transparent,
        child: Row(
          children: [
            // Left Side Icons (Now Interactive)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: LeftSideIcons(),
            ),
            Spacer(),
            // Window Buttons (Now Interactive)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: WindowButtons(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

/// **Left Side Icons (Now Fully Responsive)**
class LeftSideIcons extends StatelessWidget {
  const LeftSideIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _iconButton('assets/icons/tabler--menu-2.svg', "Menu"),
        _iconButton('assets/icons/tabler--folder-open.svg', "Open"),
        _iconButton('assets/icons/tabler--search.svg', "Search"),
      ],
    );
  }

  /// **Private method for optimized icon buttons**
  static Widget _iconButton(String assetPath, String tooltip) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures fast response
      child: IconButton(
        icon: SvgPicture.asset(
          assetPath,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
        ),
        tooltip: tooltip,
        onPressed: () => debugPrint('$tooltip clicked'),
      ),
    );
  }
}

/// **Window Control Buttons (Now Responsive)**
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

/// **Main Content**
class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: const [LeftSide(), RightSide()]);
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
