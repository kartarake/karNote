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
      home: Scaffold(
        body: WindowBorder(
          color: Colors.transparent,
          child: buildAppStructure(),
        ),
      ),
    );
  }
}

Widget buildAppStructure() {
  return Stack(
    children: [
      buildAppContent(),
      buildCustomTitleBar(),
    ],
  );
}

Widget buildAppContent() {
  return Row(children: [LeftSide(), RightSide()],);
}

Widget buildCustomTitleBar() {
  return WindowTitleBarBox(
    child: MoveWindow(
      child: Row(
        children: [
          Expanded(child: leftSideIcons()),
          Spacer(),
          const WindowButtons(),
        ],
      ),
    )
  );
}

Widget leftSideIcons() {
  return Row(
    children: [
      IconButton(
        icon: SvgPicture.asset(
          'assets/icons/tabler--menu-2.svg',
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
        ),
        onPressed: () => print('Menu'),
      ),

      IconButton(
        icon: SvgPicture.asset(
          'assets/icons/tabler--folder-open.svg',
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
        ),
        onPressed: () => print('Open'),
      ),

      IconButton(
        icon: SvgPicture.asset(
          'assets/icons/tabler--search.svg',
          height: 24,
          width: 24,
          colorFilter: const ColorFilter.mode(Color(0xff818e8a), BlendMode.srcIn),
        ),
        onPressed: () => print('Search'),
      ),
    ],
  );
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF767e7d),
    mouseOver: const Color(0xFF767e7d),
    mouseDown: const Color(0xFFffffff),
    iconMouseOver: const Color(0xFF1b1f22),
    iconMouseDown: const Color(0xFFFfffff));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF767e7d),
    iconMouseOver: Colors.white);

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