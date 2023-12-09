import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'AppColors.dart';
import 'AppConstant.dart';
Widget text(
  String? text, {
  var fontSize = textSizeLargeMedium,
  Color? textColor,
  var fontFamily,
  var isCentered = false,
  var maxLine = 1,
  var latterSpacing = 0.5,
  bool textAllCaps = false,
  var isLongText = false,
  bool lineThrough = false,
}) {
  return Text(
    textAllCaps ? text!.toUpperCase() : text!,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontFamily: fontFamily ?? null,
      fontSize: fontSize,
      color: textColor ?? appStore.textSecondaryColor,
      height: 1.5,
      letterSpacing: latterSpacing,
      decoration: lineThrough ? TextDecoration.lineThrough : TextDecoration.none,
    ),
  );
}

BoxDecoration boxDecoration({double radius = 2, Color color = Colors.transparent, Color? bgColor, var showShadow = false}) {
  return BoxDecoration(
    color: bgColor ?? appStore.scaffoldBackground,
    boxShadow: showShadow ? defaultBoxShadow(shadowColor: shadowColorGlobal) : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

void changeStatusColor(Color color) async {
  setStatusBarColor(color);
}

Widget commonCacheImageWidget(String? url, double height, {double? width, BoxFit? fit}) {
  if (url.validate().startsWith('http')) {
    if (isMobile) {
      return CachedNetworkImage(
        placeholder: placeholderWidgetFn() as Widget Function(BuildContext, String)?,
        imageUrl: '$url',
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorWidget: (_, __, ___) {
          return SizedBox(height: height, width: width);
        },
      );
    } else {
      return Image.network(url!, height: height, width: width, fit: fit ?? BoxFit.cover);
    }
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit ?? BoxFit.cover);
  }
}





String convertDate(date) {
  try {
    return date != null ? DateFormat(dateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    print(e);
    return '';
  }
}


Widget? Function(BuildContext, String) placeholderWidgetFn() => (_, s) => placeholderWidget();

Widget placeholderWidget() => Image.asset('images/app/placeholder.jpg', fit: BoxFit.cover);

BoxConstraints dynamicBoxConstraints({double? maxWidth}) {
  return BoxConstraints(maxWidth: maxWidth ?? applicationMaxWidth);
}

double dynamicWidth(BuildContext context) {
  return isMobile ? context.width() : applicationMaxWidth;
}

/*class ContainerX extends StatelessWidget {
  static String tag = '/ContainerX';
  final BuildContext context;
  final double maxWidth;
  final Widget child;

  ContainerX({@required this.context, this.maxWidth, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      height: context.height(),
      child: ConstrainedBox(
        constraints: dynamicBoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
      alignment: Alignment.topCenter,
    );
  }
}*/

String? getBannerAdUnitId() {
  if (kReleaseMode) {
    if (Platform.isIOS) {
      return bannerAdIdForIos;
    } else if (Platform.isAndroid) {
      return bannerAdIdForAndroidRelease;
    }
  } else {
    if (Platform.isIOS) {
      return bannerAdIdForIos;
    } else if (Platform.isAndroid) {
      return bannerAdIdForAndroid;
    }
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (kReleaseMode) {
    if (Platform.isIOS) {
      return interstitialAdIdForIos;
    } else if (Platform.isAndroid) {
      return InterstitialAdIdForAndroidRelease;
    }
  } else {
    if (Platform.isIOS) {
      return interstitialAdIdForIos;
    } else if (Platform.isAndroid) {
      return InterstitialAdIdForAndroid;
    }
  }

  return InterstitialAdIdForAndroid;
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

class ContainerX extends StatelessWidget {
  final Widget? mobile;
  final Widget? web;
  final bool? useFullWidth;

  ContainerX({this.mobile, this.web, this.useFullWidth});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.device == DeviceSize.mobile) {
          return mobile ?? SizedBox();
        } else {
          return Container(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: useFullWidth.validate() ? null : dynamicBoxConstraints(maxWidth: context.width() * 0.9),
              child: web ?? SizedBox(),
            ),
          );
        }
      },
    );
  }
}
