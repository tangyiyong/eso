import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:eso/utils/text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class UINovelMenu extends StatelessWidget {
  final SearchItem searchItem;
  const UINovelMenu({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
    final color = Theme.of(context).textTheme.bodyText1.color;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: _buildTopRow(context, bgColor, color),
        ),
        provider.showSetting
            ? _buildSetting(context, bgColor, color)
            : _buildBottomRow(context, bgColor, color),
      ],
    );
  }

  Widget _buildSetting(BuildContext context, Color bgColor, Color color) {
    final provider = Provider.of<NovelPageProvider>(context);
    final profile = Provider.of<Profile>(context);
    final colors = [
      [0xfff1f1f1, 0xff373534], //白底
      [0xfff5ede2, 0xff373328], //浅黄
      [0xFFF5DEB3, 0xff373328], //黄
      [0xffe3f8e1, 0xff485249], //绿
      [0xff999c99, 0xff353535], //浅灰
      [0xff33383d, 0xffc5c4c9], //黑
    ];
    final styles = [
      ["滚动", Profile.novelScroll],
      // ["滑动", Profile.novelSlide],
      // ["覆盖", Profile.novelCover],
      // ["仿真", Profile.novelSimulation],
      ["上下滑动", Profile.novelVerticalSlide],
      ["左右滑动", Profile.novelHorizontalSlide],
      ["无", Profile.novelNone],
    ];
    return IconTheme(
      data: IconThemeData(size: 22, color: color),
      child: Container(
        width: double.infinity,
        color: bgColor,
        padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("亮度", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: FlutterSlider(
                      values: [provider.brightness * 100],
                      max: 100,
                      min: 0,
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        provider.brightness = lowerValue / 100;
                      },
                      // disabled: provider.isLoading,
                      handlerWidth: 6,
                      handlerHeight: 14,
                      handler: FlutterSliderHandler(
                        decoration: BoxDecoration(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: bgColor,
                            border: Border.all(color: color.withOpacity(0.65), width: 1),
                          ),
                        ),
                      ),
                      trackBar: FlutterSliderTrackBar(
                        inactiveTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: color.withOpacity(0.5),
                        ),
                        activeTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      tooltip: FlutterSliderTooltip(
                        disableAnimation: true,
                        custom: (value) => Container(
                          padding: EdgeInsets.all(8),
                          color: bgColor,
                          child: Text((value as double).toStringAsFixed(0)),
                        ),
                        positionOffset:
                            FlutterSliderTooltipPositionOffset(left: -20, right: -20),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("常亮"),
                  Switch(
                    value: profile.novelKeepOn,
                    onChanged: (value) {
                      profile.novelKeepOn = value;
                      provider.setKeepOn(value);
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("上下", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove),
                          onTap: () => profile.novelTopPadding -= 5,
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^\d{0,2}$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelTopPadding.toStringAsFixed(0),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelTopPadding.toStringAsFixed(0),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 4, top: 4),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelTopPadding = double.parse(value),
                          ),
                        ),
                        InkWell(
                          child: Icon(Icons.add),
                          onTap: () => profile.novelTopPadding += 5,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 50,
                    child: Text("左右", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove),
                          onTap: () => profile.novelLeftPadding -= 5,
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^\d{0,2}$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelLeftPadding.toStringAsFixed(0),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelLeftPadding.toStringAsFixed(0),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 4, top: 4),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelLeftPadding = double.parse(value),
                          ),
                        ),
                        InkWell(
                          child: Icon(Icons.add),
                          onTap: () => profile.novelLeftPadding += 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("行高", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove),
                          onTap: () => profile.novelHeight -= 0.5,
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^\d?(\.\d?)?$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelHeight.toStringAsFixed(1),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelHeight.toStringAsFixed(1),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 4, top: 4),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelHeight = double.parse(value),
                          ),
                        ),
                        InkWell(
                          child: Icon(Icons.add),
                          onTap: () => profile.novelHeight += 0.5,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 50,
                    child: Text("段距", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove),
                          onTap: () => profile.novelParagraphPadding -= 5,
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^\d{0,2}$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelParagraphPadding.toStringAsFixed(0),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelParagraphPadding.toStringAsFixed(0),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 4, top: 4),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelParagraphPadding = double.parse(value),
                          ),
                        ),
                        InkWell(
                          child: Icon(Icons.add),
                          onTap: () => profile.novelParagraphPadding += 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("字号", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove),
                          onTap: () => profile.novelFontSize -= 2,
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^\d{0,2}$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelFontSize.toStringAsFixed(0),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelFontSize.toStringAsFixed(0),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 4, top: 4),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelFontSize = double.parse(value),
                          ),
                        ),
                        InkWell(
                          child: Icon(Icons.add),
                          onTap: () => profile.novelFontSize += 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 50,
                    child: Text("缩进", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove),
                          onTap: () => profile.novelIndentation -= 1,
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^(0|1|2|3|4)?$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelIndentation.toString(),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelIndentation.toString(),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 4, top: 4),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelIndentation = int.parse(value),
                          ),
                        ),
                        InkWell(
                          child: Icon(Icons.add),
                          onTap: () => profile.novelIndentation += 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    child: Text("翻页", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: styles
                          .map((style) => Container(
                                height: 32,
                                width: 32.0 + (style[0] as String).length * 14,
                                child: OutlineButton(
                                  child: Text(style[0], style: TextStyle(color: color)),
                                  onPressed: () => profile.novelPageSwitch = style[1],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide(color: color),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    child: Text("背景", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: colors
                          .map((color) => InkWell(
                                child: CircleAvatar(
                                  radius: 18.0,
                                  backgroundColor: Color(color[0]),
                                ),
                                onTap: () => profile.setNovelColor(color[0], color[1]),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, Color bgColor, Color color) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(color: bgColor),
      padding: EdgeInsets.fromLTRB(12, 4 + MediaQuery.of(context).padding.top, 12, 4),
      child: Row(
        children: <Widget>[
          InkWell(
            child: Icon(Icons.arrow_back_ios, color: color, size: 26),
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${searchItem.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, color: color),
                ),
                searchItem.author.isEmpty
                    ? Text(
                        '${searchItem.author}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12, color: color.withOpacity(0.75)),
                      )
                    : Container(),
              ],
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            child: Icon(Icons.share, color: color, size: 26),
            onTap: Provider.of<NovelPageProvider>(context, listen: false).share,
          ),
          _buildPopupmenu(context, bgColor, color),
        ],
      ),
    );
  }

  Widget _buildPopupmenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const SELECTABLE = 2;
    const ADD_ITEM = 3;
    const REFRESH = 4;
    final primaryColor = Theme.of(context).primaryColor;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.more_vert, color: color, size: 26),
      color: bgColor,
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case TO_CLICPBOARD:
            Clipboard.setData(
                ClipboardData(text: searchItem.chapters[searchItem.durChapterIndex].url));
            Toast.show(
                "已复制地址\n" + searchItem.chapters[searchItem.durChapterIndex].url, context);
            break;
          case LAUCH:
            launch(searchItem.chapters[searchItem.durChapterIndex].url);
            break;
          case SELECTABLE:
            if (provider.useSelectableText) {
              provider.useSelectableText = false;
            } else {
              provider.useSelectableText = true;
              provider.showSetting = false;
              provider.showMenu = false;
            }
            break;
          case ADD_ITEM:
            (() async {
              final success = await provider.addToFavorite();
              if (null == success) {
                Toast.show("已在收藏中", context, duration: 1);
              } else if (success) {
                Toast.show("添加收藏成功！", context, duration: 1);
              } else {
                Toast.show("添加收藏失败！", context, duration: 1);
              }
            })();
            break;
          case REFRESH:
            provider.refreshCurrent();
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('复制原地址'),
              Icon(Icons.content_copy, color: primaryColor),
            ],
          ),
          value: TO_CLICPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('查看原页面'),
              Icon(Icons.launch, color: primaryColor),
            ],
          ),
          value: LAUCH,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('重新加载'),
              Icon(Icons.refresh, color: primaryColor),
            ],
          ),
          value: REFRESH,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(provider.useSelectableText ? '退出复制模式' : '进入复制模式'),
              Icon(
                provider.useSelectableText ? Icons.flip_to_back : Icons.flip_to_front,
                color: primaryColor,
              ),
            ],
          ),
          value: SELECTABLE,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('加入收藏'),
              Icon(
                Icons.add_to_photos,
                color: primaryColor,
              ),
            ],
          ),
          value: ADD_ITEM,
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, Color bgColor, Color color) {
    final provider = Provider.of<NovelPageProvider>(context);
    return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                InkWell(
                  child: Text(
                    '章节',
                    style: TextStyle(color: color),
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FlutterSlider(
                    values: [(searchItem.durChapterIndex + 1) * 1.0],
                    max: searchItem.chaptersCount * 1.0,
                    min: 1,
                    step: FlutterSliderStep(step: 1),
                    onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                      provider.loadChapter((lowerValue as double).toInt() - 1);
                    },
                    // disabled: provider.isLoading,
                    handlerWidth: 6,
                    handlerHeight: 14,
                    handler: FlutterSliderHandler(
                      decoration: BoxDecoration(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: bgColor,
                          border: Border.all(color: color.withOpacity(0.65), width: 1),
                        ),
                      ),
                    ),
                    trackBar: FlutterSliderTrackBar(
                      inactiveTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: color.withOpacity(0.5),
                      ),
                      activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    touchSize: 30,
                    tooltip: FlutterSliderTooltip(
                      disableAnimation: true,
                      absolutePosition: true,
                      positionOffset: FlutterSliderTooltipPositionOffset(
                        left: -20,
                        top: -20,
                        right: 160 - MediaQuery.of(context).size.width,
                      ),
                      custom: (value) {
                        final index = (value as double).toInt();
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          color: bgColor,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                searchItem.chapters[index - 1].name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "$index / ${searchItem.chaptersCount}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color.withOpacity(0.7),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  child: Text(
                    '共${searchItem.chaptersCount}章',
                    style: TextStyle(color: color),
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Column(
                    children: [
                      Icon(Icons.arrow_back, color: color, size: 28),
                      Text("上一章", style: TextStyle(color: color))
                    ],
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
                ),
                InkWell(
                  child: Column(
                    children: [
                      Icon(Icons.format_list_bulleted, color: color, size: 28),
                      Text("目录", style: TextStyle(color: color))
                    ],
                  ),
                  onTap: () => provider.showChapter = !provider.showChapter,
                ),
                InkWell(
                  child: Column(
                    children: [
                      Icon(Icons.text_format, color: color, size: 28),
                      Text("调节", style: TextStyle(color: color))
                    ],
                  ),
                  onTap: () {
                    provider.showChapter = false;
                    provider.showSetting = true;
                  },
                ),
                InkWell(
                  child: Column(
                    children: [
                      Icon(Icons.arrow_forward, color: color, size: 28),
                      Text("下一章", style: TextStyle(color: color))
                    ],
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
