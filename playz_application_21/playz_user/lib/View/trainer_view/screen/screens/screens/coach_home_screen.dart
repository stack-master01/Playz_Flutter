import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Note: Assuming these imports are correct and available
import 'package:playz_user/Controller/trainer_sharedpreferences.dart'; // Used in mock setup
import 'package:playz_user/Controller/Trainer_Controller/Trainer_Profile_Controller.dart';
import 'package:playz_user/Helper/Trainer_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart'; // Used in mock setup
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart'; // Used in mock setup

// --- GLOBAL MOCK DATA/UTILITIES ---
Map<String, String> _translationsCache = {};
const List<Map<String, dynamic>> turfInfo = [];
String _currentLang = "en";

// ⭐️ DUMMY REVIEW DATA
const List<Map<String, dynamic>> _dummyReviews = [
  {
    "name": "Arjun Varma",
    "rating": 5.0,
    "comment": "Best cricket coaching I've received! Highly recommend to everyone.",
    "date": "2 days ago",
  },
  {
    "name": "Priya Singh",
    "rating": 4.5,
    "comment": "Great technique sessions. Coach Amit is very knowledgeable.",
    "date": "5 days ago",
  },
  {
    "name": "Karan Mehta",
    "rating": 4.0,
    "comment": "Good intensity training. Needs a bit more focus on fitness drills.",
    "date": "1 week ago",
  },
];

// Helper to recursively extract strings from fetched data structures
void _extractStrings(dynamic data, Set<String> keys) {
  if (data is String) {
    // Add the string if it's not empty and potentially not a URL/ID
    // For translation purposes, you might want to filter out IDs, URLs, etc.
    // For simplicity here, we add all strings.
    if (data.isNotEmpty) {
      keys.add(data);
    }
  } else if (data is Map) {
    data.values.forEach((value) => _extractStrings(value, keys));
  } else if (data is List) {
    data.forEach((item) => _extractStrings(item, keys));
  }
  // Ignore other types like int, double, bool, null, etc.
}

/// Trainer Home Screen
class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final TrainerProfileController _profileController = TrainerProfileController();
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;
  // 1. Translation Cache Map

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    final Set<String> keys = {
      // 📝 Static Translation Keys from the screen
      "Coach Dashboard",
      "Welcome, Coach!",
      "Sessions Today",
      "People Interested",
      "Reviews & Ratings", // ⭐️ Replaced "Today's Sessions"
      "days ago",
      "week ago",
    };

    // Extract dynamic strings from known data sources so they get
    // included in the translation load (turfInfo, dummy/fetched reviews)
    _extractStrings(turfInfo, keys);
    _extractStrings(_dummyReviews, keys);
    _extractStrings(_reviews, keys);

    return keys.toList();
  }

  // 3. Load Translations function (Unchanged)
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = await getTranslatedText(key, lang);
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  // Listener function to call _loadTranslations when the language notifier changes (Unchanged)
  void _languageChangeListener() {
    _loadTranslations(trainerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != trainerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    trainerAppLanguageNotifier.addListener(_languageChangeListener);
    _loadTrainerReviews();
  }

  Future<void> _loadTrainerReviews() async {
    setState(() {
      _loadingReviews = true;
    });
    try {
      final reviews = await _profileController.fetchTrainerReviews();
      if (mounted) {
        setState(() {
          _reviews = reviews;
        });
      }
    } catch (e) {
      // ignore for now
    } finally {
      if (mounted) {
        setState(() {
          _loadingReviews = false;
        });
      }
    }
  }

  @override
  void dispose() {
    trainerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await TrainerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await TrainerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    trainerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  // 4. Helper to retrieve cached translation (Unchanged)
  String _getTranslation(String key) {
    return _translationsCache[key] ?? key;
  }
  
  // 🔸 Helper for rating stars
  Widget _buildStarRating(double rating, ThemeData theme) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: theme.colorScheme.primary, size: 20));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: theme.colorScheme.primary, size: 20));
      } else {
        stars.add(Icon(Icons.star_border, color: theme.colorScheme.onSurface.withOpacity(0.38), size: 20));
      }
    }
    
    return Row(children: stars);
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
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: theme.colorScheme.background,

                // 🔸 Top Bar (contrasting and separated from body)
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 4,
                  // Subtle bottom separator so appbar doesn't camouflage with body
                  shape: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: theme.colorScheme.primary,
                    statusBarIconBrightness:
                        isDarkMode ? Brightness.light : Brightness.dark,
                    statusBarBrightness:
                        isDarkMode ? Brightness.dark : Brightness.light,
                  ),
                 
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications_none,
                          color: theme.colorScheme.onPrimary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.chat_bubble_outline,
                          color: theme.colorScheme.onPrimary),
                      onPressed: () {},
                    ),
                   
                    const SizedBox(width: 10),
                  ],
                ),

                // 🔹 Sidebar Drawer
                drawer:  TrainerDrawer(),

                // 🔹 Main Body
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslation("Welcome, Coach!"),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Top Stats Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatBox(
                                "3",
                                _getTranslation("Sessions Today"),
                                theme),
                            _buildStatBox(
                                "25",
                                _getTranslation("People Interested"),
                                theme),
                          ],
                        ),

                        const SizedBox(height: 30),
                        
                        // ⭐️ NEW SECTION TITLE
                        Text(
                          _getTranslation("Reviews & Ratings"), 
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ⭐️ REVIEW LIST
                        // Use a Column or ListView.builder to display the reviews
                        if (_loadingReviews)
                          SizedBox(
                            height: 160,
                            child: Center(),
                          )
                        else if (_reviews.isEmpty)
                          SizedBox(
                            height: 120,
                            child: Center(
                              child: Text(
                                _getTranslation('No reviews yet'),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _reviews.map((review) {
                              return _buildReviewCard(theme, _getTranslation, review);
                            }).toList(),
                          ),
                        
                        const SizedBox(height: 25),

                        // ❌ REMOVED: Reviews Button (SizedBox/ElevatedButton)
                      ],
                    ),
                  ),
                ),
              ),
              if (_translationsCache.isEmpty || _loadingReviews)
                Positioned.fill(child: TrainerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Helper Widget for top boxes (Unchanged)
  Widget _buildStatBox(
      String value, String labelKey, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.9), width: 1),
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.surfaceVariant,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labelKey,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ❌ REMOVED: _buildSessionCard

  // ⭐️ NEW Helper Widget for Review Card
  Widget _buildReviewCard(
    ThemeData theme,
    String Function(String) getTranslation,
    Map<String, dynamic> reviewData,
  ) {
    // Support multiple review shapes: prefer trainer-specific keys
    final String name = (reviewData['senders_name'] ?? reviewData['name'] ?? 'Anonymous') as String;
    final dynamic starsRaw = reviewData['stars'] ?? reviewData['rating'] ?? 0;
    final double rating = (starsRaw is num) ? starsRaw.toDouble() : double.tryParse(starsRaw.toString()) ?? 0.0;
    final String comment = (reviewData['message'] ?? reviewData['comment'] ?? '') as String;
    final String date = (reviewData['date'] ?? '') as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if ((reviewData['sender_profile'] ?? reviewData['image_url']) != null)
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
                        image: DecorationImage(
                          image: NetworkImage((reviewData['sender_profile'] ?? reviewData['image_url']) as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Star Rating
          _buildStarRating(rating, theme),
          const SizedBox(height: 10),
          // Comment
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}