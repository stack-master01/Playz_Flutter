import 'package:flutter/material.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/coach_home_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/coach_sessions_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/profile_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/sessions_screen.dart.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/students_page.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';

class TrainerNavigation extends StatefulWidget {
  const TrainerNavigation({super.key});

  @override
  State<TrainerNavigation> createState() => _WorkernavigatorScreenState();
}

class _WorkernavigatorScreenState extends State<TrainerNavigation> {
  int currentIndex = 0;

  final List<Widget> _pages = [
    const CoachHomeScreen(),
    // const CoachSessionsScreen(),
    const CoachStudentsScreen(),
    const CoachProfileScreen(),

  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await TrainerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTrainerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Scaffold(
            // Use a background that contrasts with any patterned or surface widgets inside pages
            backgroundColor: theme.colorScheme.background,
            drawer: const TrainerDrawer(),
            body: _pages[currentIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                showUnselectedLabels: true,
                currentIndex: currentIndex,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor:
                    theme.colorScheme.onSurface.withOpacity(0.6),
                selectedIconTheme:
                    IconThemeData(color: theme.colorScheme.primary),
                unselectedIconTheme: IconThemeData(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home,
                        color: currentIndex == 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6)),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group,
                        color: currentIndex == 1
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6)),
                    label: "Students",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline,
                        color: currentIndex == 2
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6)),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
