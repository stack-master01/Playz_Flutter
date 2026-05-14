import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/Bookings_Screen.dart';
import 'package:playz_user/View/owner_view/ForgotPassword_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/Login_Screen.dart';
import 'package:playz_user/View/owner_view/MainTurfWorker_Screen.dart';
import 'package:playz_user/View/owner_view/Notification_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/Turf_Screen.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
  Map<String, String> _translationsCache = {};

  String _currentLang = "en";





// Mock Translation Service (for testing the load function)


// Mock Theme/Lang Settings Storage Class


// Mock CustomThemes to prevent errors

// ----------------------------------------------------------------------

class owner_Review_Screen extends StatefulWidget {
  // Accept reviews, averageStars and totalReviews from caller
  final List<Map<String, dynamic>>? reviews;
  final double? averageStars;
  final int? totalReviews;

  const owner_Review_Screen({super.key, this.reviews, this.averageStars, this.totalReviews});

  @override
  State<owner_Review_Screen> createState() => _owner_Review_ScreenState();
}

class _owner_Review_ScreenState extends State<owner_Review_Screen> {
  // 1. Translation Cache Map

  // Current language to track changes

  int selected = 0;

  // Local copy of reviews; initialized from widget.reviews if provided
  late List<Map<String, dynamic>> reviews;

  TextEditingController replyController1 = TextEditingController();
  TextEditingController replyController2 = TextEditingController();
  TextEditingController replyController3 = TextEditingController();
  late List<TextEditingController> editor;
  int editingIndex = -1;

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Turf Owner",
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Today's Income", "This Week's Income", "This Month's Income", "This Year's Income",
      "Reviews & Ratings",
      "INR 8900", "INR 53900", "INR 238900", "INR 3253900",
      "Income", "Expenditure", // Keys used in PieChart
      // Add specific keys used in this screen's UI for a real app
      "MENU", "Notifications", "App Language", "Contact Us", "FAQ", "Set Password", 
      "Delete Account", "Privacy Policy", "About App", "LOGOUT", "Are you sure you want to delete your account?", 
      "Cancel", "Confirm", "Account Deleted", "Logout", "Are you sure you want to Logout?", "Logged Out", 
      "Home", "Bookings", "Turf", "Workers", "Customer Reviews & Ratings", "Edit", "Reply here", "Reply", "Save"
    };

    // Add dynamic keys from the turfInfo list
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName']);
      }
    }

       final allLocalReviews = [...reviews];
    for (var review in allLocalReviews) {
      if (review['userName'] != null && review['comment'] != null) {
        keys.add(review['userName']!);
         keys.add(review['comment']!);
      }
    }

    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    // Simple check: if the language is the same and the number of keys matches the cached count, skip.
    // NOTE: This check is basic; for production, you might want a more robust check
    // to see if any *new* dynamic keys were added.
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
_translationsCache.clear();
    _currentLang = lang;
    Map<String, String> newTranslations = {};

    // Fetch all translations
    for (String key in keysToLoad) {
      // NOTE: getTranslatedText must be an available function (Mocked above)
      String translated = await getTranslatedText(key, lang);
      newTranslations[key] = translated;
    }

    // Update state to trigger a re-render with cached values
    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await OwnerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await OwnerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }
  // End of Translation Logic

  Map<int, int> getStarCount() {
    Map<int, int> starMap = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      int rating = 0;
      final rv = r['rating'];
      if (rv is int) rating = rv;
      else if (rv is num) rating = rv.toInt();
      else if (rv is String) rating = int.tryParse(rv) ?? 0;
      if (starMap.containsKey(rating)) starMap[rating] = starMap[rating]! + 1;
    }
    return starMap;
  }

  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    int total = 0;
    for (var r in reviews) {
      // support both 'rating' and 'stars' keys (and string/num types)
      final rv = r['rating'] ?? r['stars'];
      int rating = 0;
      if (rv is int) rating = rv;
      else if (rv is num) rating = rv.toInt();
      else if (rv is String) rating = int.tryParse(rv) ?? 0;
      total += rating;
    }
    return reviews.isNotEmpty ? total / reviews.length : 0.0;
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // initialize editors to match incoming reviews length
    // Initialize reviews from constructor if provided, else use defaults
    reviews = widget.reviews != null
        ? widget.reviews!.map((e) => Map<String, dynamic>.from(e)).toList()
        : [
            {
              'userName': 'Amit C.',
              'rating': 5,
              'comment': 'Great experience at the turf! The ground was well maintained.',
              'ownerReply': '',
            },
            {
              'userName': 'Priya S.',
              'rating': 4,
              'comment': 'Good facilities, wish customer support was faster.',
              'ownerReply': '',
            },
            {
              'userName': 'John D.',
              'rating': 3,
              'comment': 'Average experience. Turf was busy.',
              'ownerReply': '',
            },
          ];
      // create a TextEditingController for each review for owner replies
      editor = List<TextEditingController>.generate(reviews.length, (index) => TextEditingController());
    // --- START OF CACHED TRANSLATION INIT LOGIC ---
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
    // --- END OF CACHED TRANSLATION INIT LOGIC ---
  }

  @override
  void dispose() {
    // --- START OF CACHED TRANSLATION DISPOSE LOGIC ---
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    // --- END OF CACHED TRANSLATION DISPOSE LOGIC ---
    // dispose dynamic editors
    for (var c in editor) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   

  double avgRating = widget.averageStars ?? getAverageRating();
  int totalReviewsCount = widget.totalReviews ?? reviews.length;

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        final primaryColor = theme.colorScheme.primary;
        final onPrimary = theme.colorScheme.onPrimary;
        final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
        final cardColor = theme.cardColor;
        final surfaceColor = theme.colorScheme.surface;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: onPrimary, size: 25),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Text(
                    _getTranslation("Turf Owner"), // Translated
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: onPrimary),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner_outlined,
                          color: onPrimary, size: 25),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingQRScannerScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.message_outlined, color: onPrimary, size: 25),
                      onPressed: () {},
                    ),
                  ],
                ),
              
                // DRAWER
                drawer: Drawer(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Container(
                    color: surfaceColor,
                    child: Column(
                      children: [
                        SizedBox(height: 36),
                        ListTile(
                          title: Text(
                            _getTranslation("MENU"), // Translated
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 25,
                            ),
                          ),
                        ),
                        Divider(),
                        _drawerItem(
                          icon: Icons.notifications_outlined,
                          label: _getTranslation('Notifications'), // Translated
                          color: primaryColor,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ownerNotificationScreen())),
                        ),
                        _drawerItem(
                          icon: Icons.language,
                          label: _getTranslation('App Language'), // Translated
                          color: primaryColor,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ownerLanguageScreen())),
                        ),
                        Divider(),
                        _drawerItem(
                          icon: Icons.support_agent_outlined,
                          label: _getTranslation('Contact Us'), // Translated
                          color: primaryColor,
                          onTap: () {},
                        ),
                        _drawerItem(
                          icon: Icons.help_outline,
                          label: _getTranslation('FAQ'), // Translated
                          color: primaryColor,
                          onTap: () {},
                        ),
                        Divider(),
                        _drawerItem(
                          icon: Icons.lock_outline,
                          label: _getTranslation('Set Password'), // Translated
                          color: primaryColor,
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ownerForgotPasswordScreen()),
                            (route) => false,
                          ),
                        ),
                        _drawerItem(
                          icon: Icons.delete_outline,
                          label: _getTranslation('Delete Account'), // Translated
                          color: primaryColor,
                          onTap: () => _showDeleteDialog(context, theme),
                        ),
                        Divider(),
                        _drawerItem(
                          icon: Icons.privacy_tip_outlined,
                          label: _getTranslation('Privacy Policy'), // Translated
                          color: primaryColor,
                          onTap: () {},
                        ),
                        _drawerItem(
                          icon: Icons.info_outline,
                          label: _getTranslation('About App'), // Translated
                          color: primaryColor,
                          onTap: () {},
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () => _showLogoutDialog(context, theme),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(_getTranslation("LOGOUT"), // Translated
                                  style: TextStyle(color: onPrimary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
                // BODY
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getTranslation("Customer Reviews & Ratings"), // Translated
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(avgRating.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          Text("/5.0",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.grey[600])),
                          SizedBox(width: 10),
                          // show total reviews count if available
                          Text('(${totalReviewsCount.toString()} reviews)', style: TextStyle(color: Colors.grey[600])),
                          SizedBox(width: 10),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    Icons.star,
                                    color: i < avgRating ? Colors.amber : Colors.grey,
                                    size: 28,
                                  );
                                }),
                              ),
                        ],
                      ),
                      SizedBox(height: 20),
              
                      // Review Cards
                      ...List.generate(reviews.length, (index) {
                        var review = reviews[index];
                        bool isEditing = editingIndex == index;
                        return Card(
                          color: cardColor,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                        // sender name (support incoming key names)
                                        Text((review['senders_name'] ?? review['userName'] ?? review['senderName'])?.toString() ?? 'user',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor)),
                                    SizedBox(width: 10),
                                        Row(
                                          children: List.generate(5, (i) {
                                            final rv = review['rating'] ?? review['stars'];
                                            int rVal = 0;
                                            if (rv is int) rVal = rv;
                                            else if (rv is num) rVal = rv.toInt();
                                            else if (rv is String) rVal = int.tryParse(rv) ?? 0;
                                            return Icon(
                                              Icons.star,
                                              color: i < rVal ? Colors.amber : Colors.grey[300],
                                              size: 18,
                                            );
                                          }),
                                        ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                    Text((review['message'] ?? review['comment'] ?? '').toString(),
                                      style: TextStyle(color: textColor)),
                                SizedBox(height: 10),
              
                                // Reply UI
                                if ((review['ownerReply'] ?? '').toString().isNotEmpty && !isEditing)
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.reply,
                                                color: primaryColor, size: 16),
                                            SizedBox(width: 4),
                                            Text(review['ownerReply'] ?? '',
                                                style: TextStyle(color: primaryColor)),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      TextButton(
                                        child: Text(_getTranslation("Edit"), // Translated
                                            style: TextStyle(color: primaryColor)),
                                        onPressed: () {
                                            setState(() {
                                              editingIndex = index;
                                              editor[index].text = (review['ownerReply'] ?? '').toString();
                                            });
                                        },
                                      ),
                                    ],
                                  ),
                                if (review['ownerReply']==null || isEditing)
                                  Column(
                                    children: [
                                      TextField(
                                        controller: editor[index],
                                        decoration: InputDecoration(
                                          hintText: _getTranslation("Reply here"), // Translated
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              reviews[index]['ownerReply'] =
                                                  editor[index].text;
                                              editor[index].clear();
                                              editingIndex = -1;
                                            });
                                          },
                                          child: Text(
                                              _getTranslation(isEditing ? "Save" : "Reply")), // Translated
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              
                // Bottom Nav
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: primaryColor,
                  items: [
                    BottomBarItem(
                        icon: Icon(Icons.home, color: onPrimary),
                        title: Text(_getTranslation('Home'), style: TextStyle(color: onPrimary))), // Translated
                    BottomBarItem(
                        icon: Icon(Icons.calendar_month_sharp, color: onPrimary),
                        title:
                            Text(_getTranslation('Bookings'), style: TextStyle(color: onPrimary))), // Translated
                    BottomBarItem(
                        icon: Icon(Icons.sports_basketball, color: onPrimary),
                        title: Text(_getTranslation('Turf'), style: TextStyle(color: onPrimary))), // Translated
                    BottomBarItem(
                        icon: Icon(Icons.people_rounded, color: onPrimary),
                        title: Text(_getTranslation('Workers'), style: TextStyle(color: onPrimary))), // Translated
                  ],
                  option: DotBarOptions(
                    dotStyle: DotStyle.circle,
                    gradient: LinearGradient(
                      colors: [onPrimary, onPrimary],
                    ),
                  ),
                  hasNotch: true,
                  currentIndex: selected,
                  onTap: (index) {
                    setState(() => selected = index);
                    switch (index) {
                      case 1:
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => ownerBookingScreen()));
                        break;
                      case 2:
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ownerAfterRegistrationTurfScreen()));
                        break;
                      case 3:
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ownerTurfWorkerScreen()));
                        break;
                    }
                  },
                ),
              ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, // Label is already translated
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      onTap: onTap,
      trailing: Icon(Icons.chevron_right, color: color),
    );
  }

  void _showDeleteDialog(BuildContext context, ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTranslation("Delete Account")), // Translated
        content: Text(_getTranslation("Are you sure you want to delete your account?")), // Translated
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(_getTranslation("Cancel"))), // Translated
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(_getTranslation("Confirm")), // Translated
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => OwnerLoginScreen()),
                (route) => true,
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(_getTranslation("Account Deleted")))); // Translated
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTranslation("Logout")), // Translated
        content: Text(_getTranslation("Are you sure you want to Logout?")), // Translated
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(_getTranslation("Cancel"))), // Translated
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(_getTranslation("Confirm")), // Translated
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => OwnerLoginScreen()),
                (route) => true,
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(_getTranslation("Logged Out")))); // Translated
            },
          ),
        ],
      ),
    );
  }
}