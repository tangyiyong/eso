import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'text_composition.dart';

class TextCompositionPage extends StatefulWidget {
  TextCompositionPage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextComposition controller;

  @override
  TextCompositionPageState createState() => TextCompositionPageState();
}

class TextCompositionPageState extends State<TextCompositionPage>
    with TickerProviderStateMixin {
  @override
  void didUpdateWidget(TextCompositionPage oldWidget) {
    if (!identical(oldWidget.controller, widget.controller)) setUp();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(refresh);
    widget.controller.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  setUp() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    widget.controller.addListener(refresh);
    widget.controller.init((_controllers) {
      if (_controllers.length == TextComposition.TOTAL) return;
      for (var i = 0, len = TextComposition.TOTAL; i < len; i++) {
        _controllers.add(AnimationController(
          value: 1,
          duration: widget.controller.duration,
          vsync: this,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, dimens) => RawKeyboardListener(
          focusNode: new FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (event.runtimeType.toString() == 'RawKeyUpEvent') return;
            if (event.data is RawKeyEventDataMacOs ||
                event.data is RawKeyEventDataLinux ||
                event.data is RawKeyEventDataWindows) {
              final logicalKey = event.data.logicalKey;
              print(logicalKey);
              if (logicalKey == LogicalKeyboardKey.arrowUp) {
                widget.controller.previousPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
                widget.controller.previousPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
                widget.controller.nextPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
                widget.controller.nextPage();
              } else if (logicalKey == LogicalKeyboardKey.home) {
                widget.controller.goToPage(widget.controller.firstIndex);
              } else if (logicalKey == LogicalKeyboardKey.end) {
                widget.controller.goToPage(widget.controller.lastIndex);
              } else if (logicalKey == LogicalKeyboardKey.enter ||
                  logicalKey == LogicalKeyboardKey.numpadEnter) {
                // showMenu
              } else if (logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              }
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragCancel: () => widget.controller.isForward = null,
            onHorizontalDragUpdate: (details) =>
                widget.controller.turnPage(details, dimens),
            onHorizontalDragEnd: (details) => widget.controller.onDragFinish(),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  color: const Color(0xFFFFFFCC),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.controller.name ?? ""),
                      SizedBox(height: 10),
                      Text("这是底线（最后一页）"),
                      SizedBox(height: 10),
                      Text("已读完"),
                    ],
                  ),
                ),
                ...widget.controller.pages,
                Positioned.fill(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        flex: 50,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.controller.previousPage,
                        ),
                      ),
                      Flexible(
                        flex: 50,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.controller.nextPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
