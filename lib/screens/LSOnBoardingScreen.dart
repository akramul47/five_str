import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:five_str/fragments/SearchPage.dart';
import 'package:five_str/fragments/LSHomeFragment.dart';
import 'package:five_str/fragments/LSNearByFragment.dart';
import 'package:five_str/fragments/DTReviewSceen.dart';
import 'package:five_str/fragments/LSProfileFragment.dart';
import 'package:five_str/utils/LSColors.dart';
import 'package:five_str/utils/LSImages.dart';
import 'package:nb_utils/nb_utils.dart';

class LSOnBoardingScreen extends StatefulWidget {
  static String tag = '/LSOnBoardingScreen';

  @override
  LSOnBoardingScreenState createState() => LSOnBoardingScreenState();
}

class LSOnBoardingScreenState extends State<LSOnBoardingScreen> {
  int selectedIndex = 0;

  List<Widget> viewContainer = [];

  LSHomeFragment homeFragment = LSHomeFragment();
  LSNearByFragment nearByFragment = LSNearByFragment();
  SearchPage bookingFragment = SearchPage();
  DTReviewScreen offerFragment = DTReviewScreen();
  LSProfileFragment profileFragment = LSProfileFragment();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    viewContainer = [
      homeFragment,
      nearByFragment,
      bookingFragment,
      offerFragment,
      profileFragment,
    ];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: viewContainer[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: context.scaffoldBackgroundColor,
                offset: Offset.fromDirection(3, 1),
                spreadRadius: 1,
                blurRadius: 5),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(LSHome,
                  fit: BoxFit.fitHeight,
                  color: lightGrey,
                  height: 24,
                  width: 24),
              activeIcon: SvgPicture.asset(LSHome,
                  color: LSColorPrimary, height: 24, width: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(LSPin,
                  fit: BoxFit.fitHeight,
                  color: lightGrey,
                  height: 24,
                  width: 24),
              activeIcon: SvgPicture.asset(LSPin,
                  color: LSColorPrimary, height: 24, width: 24),
              label: 'NearBy',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Search,
                  fit: BoxFit.fitHeight,
                  color: lightGrey,
                  height: 24,
                  width: 24),
              activeIcon: SvgPicture.asset(Search,
                  color: LSColorPrimary, height: 24, width: 24),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Review,
                  fit: BoxFit.fitHeight,
                  color: lightGrey,
                  height: 24,
                  width: 24),
              activeIcon: SvgPicture.asset(Review,
                  color: LSColorPrimary, height: 24, width: 24),
              label: 'Review',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(LSUser,
                  fit: BoxFit.fitHeight,
                  color: lightGrey,
                  height: 24,
                  width: 24),
              activeIcon: SvgPicture.asset(LSUser,
                  color: LSColorPrimary, height: 24, width: 24),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          unselectedIconTheme: IconThemeData(color: lightGrey, size: 24),
          selectedIconTheme: IconThemeData(color: LSColorPrimary, size: 24),
          selectedLabelStyle: TextStyle(color: LSColorPrimary),
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
