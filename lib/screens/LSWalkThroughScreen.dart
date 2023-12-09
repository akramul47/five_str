import 'package:flutter/material.dart';
import 'package:five_str/main.dart';
import 'package:five_str/model/LSWalkThroughModel.dart';
import 'package:five_str/screens/LSSignInScreen.dart';
import 'package:five_str/utils/LSColors.dart';
import 'package:five_str/utils/LSContstants.dart';
import 'package:five_str/utils/LSWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class LSWalkThroughScreen extends StatefulWidget {
  static String tag = '/LSWalkThroughScreen';

  @override
  LSWalkThroughScreenState createState() => LSWalkThroughScreenState();
}

class LSWalkThroughScreenState extends State<LSWalkThroughScreen> {
  int currentIndex = 0;
  PageController pageController = PageController();
  Color customColor = Color(int.parse('F0D9CA', radix: 16) + 0xFF000000);


  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pageController.addListener(() {
      currentIndex = pageController.page.validate().toInt();
      setState(() {});
    });
    await 2.seconds.delay;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: customColor,
            height: double.infinity,
            child: PageView.builder(
                controller: pageController,
                itemCount: lsWalkThroughList.length,
                itemBuilder: (_, index) {
                  LSWalkThroughModel data = lsWalkThroughList[index];

                  return Stack(
                    children: [
                      // commonCacheImageWidget(
                      //   data.backgroundImg.validate(),
                      //   context.height() * 0.82,
                      //   width: context.width(),
                      //   fit: BoxFit.cover,
                      // ),
                      Container(
                        // color: appStore.isDarkModeOn
                        //     ? Colors.transparent
                        //     : 
                        color: white.withOpacity(0.5),
                        height: context.height(),
                        width: context.width(),
                      ),
                      Positioned(
                        top: 10,
                        right: 0,
                        left: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            commonCacheImageWidget(data.img.validate(), 300,
                                fit: BoxFit.fitHeight),
                            // 20.height,
                            Text(data.title.validate(),
                                style: boldTextStyle(size: 26)),
                            16.height,
                            Text(fsWalkSubTitle[index],
                                    style: secondaryTextStyle(size: 16),
                                    textAlign: TextAlign.center)
                                .paddingOnly(left: 8, right: 8),
                          ],
                        ).paddingOnly(left: 8, right: 8),
                      )
                    ],
                  );
                }),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DotIndicator(
                    pageController: pageController,
                    pages: lsWalkThroughList,
                    indicatorColor: LSColorPrimary)
                .center(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: customColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                LSSignInScreen().launch(context);
              },
              child: Text('SKIP', style: boldTextStyle(color: LSColorPrimary)),
            ),
            Container(
              height: 50,
              width: currentIndex == 4 ? 90 : 50,
              color: LSColorPrimary,
              child: currentIndex == 4
                  ? Text('Start'.toUpperCase(),
                          style: boldTextStyle(color: white))
                      .center()
                  : Icon(Icons.arrow_right_alt_rounded, color: white),
            ).cornerRadiusWithClipRRect(25).onTap(
              () {
                if (currentIndex == 2) LSSignInScreen().launch(context);
                pageController.nextPage(
                    duration: Duration(milliseconds: 500), curve: Curves.ease);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(25),
            ).paddingRight(12),
          ],
        ).paddingBottom(8),
      ),
    );
  }
}
