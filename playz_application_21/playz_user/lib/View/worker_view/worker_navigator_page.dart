import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/worker_view/worker_attendance.dart';
import 'package:playz_user/View/worker_view/worker_drower.dart';
import 'package:playz_user/View/worker_view/worker_home_page.dart';
import 'package:playz_user/View/worker_view/worker_language.dart';
import 'package:playz_user/View/worker_view/worker_payment.dart';
import 'package:playz_user/View/worker_view/worker_profile.dart';

class WorkernavigatorPage extends StatefulWidget {
  const WorkernavigatorPage({super.key});

  @override
  State<WorkernavigatorPage> createState() => _WorkernavigatorScreenState();
}

class _WorkernavigatorScreenState extends State<WorkernavigatorPage> {
  int currentIndex = 0;
  // final workerEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  late final List<Widget> _pages = [
    const WorkerhomePage(),
    const WorkerAttendancePage(),
    const PaymentPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    _loadSelectedTheme();
    _loadSelectedLang();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkWorkerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    workerAppLanguageNotifier.value = langToSet;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkWorkerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Scaffold(
            drawer: WorkerDrawer(),
            body: _pages[currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: theme.colorScheme.primary,
              currentIndex: currentIndex,
              selectedItemColor: Colors.brown,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: "Attendance",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payments_outlined),
                  label: "Payment",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: "Profile",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
