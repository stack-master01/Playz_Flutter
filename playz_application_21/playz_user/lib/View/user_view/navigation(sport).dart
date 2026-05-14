import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/motiontabbar.dart';
import 'package:playz_user/View/user_view/book(sports)/book(sport).dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/play(sport)/play(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:playz_user/View/user_view/trainer(sport)/trainer(sport).dart';

class NavigationSport extends StatefulWidget {
  const NavigationSport({super.key});

  @override
  State<NavigationSport> createState() => _NavigationSportState();
}

class _NavigationSportState extends State<NavigationSport>
    with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;

  final List<Widget> _pages = [
    HomePage(),
    PlayPageSport(),
    BookSport(),
    TrainerSport(),
    MenuSport(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedColorTheme();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: _pages.length,
      vsync: this,
    );
  }

  Future<void> _loadSelectedColorTheme() async {
    String selected = await ThemeSettings(theme: null).loadSelectedTheme() ?? "Light";
    appSettingsNotifier.value.theme = selected;
    String lang = (await ThemeSettings(theme: null,locale: null).loadSelectedLocale()) ?? "en";
     appLanguageNotifier.value = lang;
    log("color theme in home page: $selected");
    log("lang in home page: $lang");
    setState(() {});
  }

  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: IndexedStack(
            index: _motionTabBarController.index,
            children: _pages,
          ),
          bottomNavigationBar: MotionTabBar(
            controller: _motionTabBarController,
            labels: const ["Home", "Play", "Book", "Train", "Menu"],
            initialSelectedTab: "Home",
            icons: const [
              Icons.home,
              Icons.sports_handball,
              Icons.sports_baseball,
              Icons.sports,
              Icons.menu,
            ],

            // Styling
            tabSize: 60,
            tabBarHeight: 60,
            textStyle: TextStyle(
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
              fontWeight: FontWeight.bold,
            ),
            tabIconColor: isDark
                ? Reusable.getLightGreen()
                : Reusable.getDarkGrey(),
            tabIconSize: 30.0,
            tabIconSelectedSize: 40.0,
            tabSelectedColor: isDark
                ? Reusable.getLightGreen()
                : Reusable.getGreen(),
            tabIconSelectedColor: isDark
                ? Reusable.getDarkModeBlack()
                : Reusable.getWhite(),
            tabBarColor: isDark
                ? Reusable.getDarkModeGrey()
                : Reusable.getLightGrey(),

            onTabItemSelected: (int value) {
              setState(() {
                _motionTabBarController.index = value;
              });
            },
          ),
        );
      },
    );
  }
}
