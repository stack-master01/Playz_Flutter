import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/Bookings_Screen.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/MainTurfWorker_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

Map<String, String> _translationsCache = {};

String _currentLang = "en";

Map<String, String> attendanceMap = {};
Map<String, String> globalAttendanceMap = {};

class OwnerWorkerDetailScreen extends StatefulWidget {
  final Map worker;

  const OwnerWorkerDetailScreen({required this.worker, Key? key})
    : super(key: key);

  @override
  State<OwnerWorkerDetailScreen> createState() =>
      _OwnerWorkerDetailScreenState();
}

class _OwnerWorkerDetailScreenState extends State<OwnerWorkerDetailScreen> {
  // 1. Translation Cache Map

  // Current language to track changes

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Turf Owner",
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Today's Income",
      "This Week's Income",
      "This Month's Income",
      "This Year's Income",
      "Reviews & Ratings",
      "INR 8900", "INR 53900", "INR 238900", "INR 3253900",
      "Income", "Expenditure", // Keys used in PieChart
      // Additional keys found in the UI
      "Contact Information",
      "Employment Details",
      "View Attendance",
      "Remove Worker",
      "Remove worker",
      "Are you sure you want to remove this worker?",
      "Cancel",
      "Remove",
      "Worker Removed",
      "Payment",
      "Attendance",
      "Home", "Bookings", "Turf", "Workers",
    };

    // Add dynamic keys from the turfInfo list
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName']);
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
    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
    _translationsCache.clear();
    _currentLang = lang;
    Map<String, String> newTranslations = {};

    // Fetch all translations
    for (String key in keysToLoad) {
      // NOTE: getTranslatedText must be an available function
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
    String? selectedTheme = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }

  int selected = 3;
  late Razorpay _razorpay;
  bool _navigated = false;

  void openCheckout({required int amount}) {
    var options = {
      'key': 'rzp_test_RRLNbb21SHGawp',
      'amount': amount,
      'name': 'Salary Payment',
      'description': 'Test transaction',
      'prefill': {'contact': '9876543210', 'email': 'test@example.com'},
      'external': {
        'wallets': ['paytm', 'phonepe', 'amazonpay'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment success with ID: ${response.paymentId}');
    if (!_navigated) {
      _navigated = true;
      Navigator.of(context).pop();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('⚠️ External wallet selected: ${response.walletName}');
  }

  @override
  void initState() {
    super.initState();

    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Translation/Theme Initialization
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  //for Image
  Widget _buildProfileImage(ThemeData theme) {
    final profileImg = widget.worker['worker_profile_image'];
    if (profileImg != null && profileImg is String && profileImg.isNotEmpty) {
      if (profileImg.startsWith('http')) {
        // It's a network URL (Firebase/HTTP image)
        return ClipOval(
          child: Image.network(
            profileImg,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.person, size: 48),
          ),
        );
      } else {
        // It's a local file path
        return ClipOval(
          child: Image.file(
            File(profileImg),
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.person, size: 48),
          ),
        );
      }
    }
    // Default fallback
    return Icon(
      Icons.person,
      size: 48,
      color: theme.colorScheme.onSecondaryContainer,
    );
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerEmail = widget.worker['email'] ?? '';
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Text(
                    _getTranslation("Turf Owner"), // Using translation helper
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: theme.colorScheme.primary,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingQRScannerScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.qr_code_scanner_outlined,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.message_outlined,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                drawer: OwnerDrawer(),
                backgroundColor: theme.colorScheme.background,
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: _buildProfileImage(theme),
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          widget.worker['worker_name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.worker['workType'] ?? '',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.7,
                            ),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildCard(
                        theme,
                        title: _getTranslation(
                          "Contact Information",
                        ), // Using translation helper
                        children: [
                          Text(
                            'Phone: ${widget.worker['contact_no'] ?? 'N/A'}',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            'Email: ${widget.worker['email'] ?? 'N/A'}',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildCard(
                        theme,
                        title: _getTranslation(
                          "Employment Details",
                        ), // Using translation helper
                        children: [
                          Text(
                            'Employment Type: ${widget.worker['skills'] != null && widget.worker['skills'] is List ? (widget.worker['skills'] as List).join(", ") : widget.worker['skills'] ?? 'N/A'}',

                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            'Date Of Birth: ${widget.worker['DOB'] ?? 'N/A'}',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            'UPI ID: ${_getTranslation(widget.worker['worker_upi_id'] ?? 'N/A')}', // Dynamic key translated
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            theme,
                            _getTranslation(
                              "View Attendance",
                            ), // Using translation helper
                            theme.colorScheme.primaryContainer,
                            () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                builder: (_) => AttendanceCalendarSheet(workerEmail: workerEmail),
                              );
                            },
                          ),
                          _buildActionButton(
                            theme,
                            _getTranslation(
                              "Remove Worker",
                            ), // Using translation helper
                            theme.colorScheme.errorContainer,
                            () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    _getTranslation("Remove worker"),
                                  ), // Using translation helper
                                  content: Text(
                                    _getTranslation(
                                      "Are you sure you want to remove this worker?",
                                    ),
                                  ), // Using translation helper
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        _getTranslation("Cancel"),
                                      ), // Using translation helper
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.error,
                                      ),
                                      child: Text(
                                        _getTranslation("Remove"),
                                      ), // Using translation helper
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ownerTurfWorkerScreen(),
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _getTranslation("Worker Removed"),
                                            ),
                                          ), // Using translation helper
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildActionButton(
                        theme,
                        _getTranslation("Payment"), // Using translation helper
                        theme.colorScheme.primary,
                        () => openCheckout(amount: 1000000),
                      ),
                      const SizedBox(height: 10),
                      _buildActionButton(
                        theme,
                        _getTranslation(
                          "Attendance",
                        ), // Using translation helper
                        theme.colorScheme.primary,
                        () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),
                            builder: (_) =>
                                MarkAttendanceSheet(workerEmail: workerEmail),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: theme.colorScheme.primary,
                  items: [
                    _bottomBarItem(
                      Icons.home,
                      _getTranslation('Home'),
                      theme,
                    ), // Using translation helper
                    _bottomBarItem(
                      Icons.calendar_month,
                      _getTranslation('Bookings'),
                      theme,
                    ), // Using translation helper
                    _bottomBarItem(
                      Icons.sports_basketball,
                      _getTranslation('Turf'),
                      theme,
                    ), // Using translation helper
                    _bottomBarItem(
                      Icons.people,
                      _getTranslation('Workers'),
                      theme,
                    ), // Using translation helper
                  ],
                  option: DotBarOptions(dotStyle: DotStyle.circle),
                  hasNotch: true,
                  currentIndex: selected,
                  onTap: (index) {
                    setState(() => selected = index);
                    switch (index) {
                      case 0:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => OwnerDashBoardScreen(),
                          ),
                        );
                        break;
                      case 1:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ownerBookingScreen(),
                          ),
                        );
                        break;
                      case 2:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ownerLanguageScreen(),
                          ),
                        );
                        break;
                      case 3:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ownerTurfWorkerScreen(),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: theme.colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    String label,
    Color bgColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 50,
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16),
        ),
      ),
    );
  }

  BottomBarItem _bottomBarItem(IconData icon, String label, ThemeData theme) {
    return BottomBarItem(
      icon: Icon(icon, color: theme.colorScheme.onPrimary),
      title: Text(label, style: TextStyle(color: theme.colorScheme.onPrimary)),
      backgroundColor: theme.colorScheme.primary,
    );
  }
}

class AttendanceCalendarSheet extends StatefulWidget {
  final String workerEmail;
  const AttendanceCalendarSheet({required this.workerEmail, Key? key})
    : super(key: key);
  @override
  _AttendanceCalendarSheetState createState() =>
      _AttendanceCalendarSheetState();
}

class _AttendanceCalendarSheetState extends State<AttendanceCalendarSheet> {
  DateTime selectedMonth = DateTime.now();
  @override
  void initState() {
    super.initState();
    fetchAttendanceDataForCurrentMonth();
  }

  Future<void> fetchAttendanceDataForCurrentMonth() async {
    attendanceMap.clear();

    // Fetch attendance for this worker for the current month
    final year = selectedMonth.year;
    final month = selectedMonth.month.toString().padLeft(2, '0');
    final workerEmail =
        widget.workerEmail; // Pass this down to the attendance sheet
    OwnerSettings _ownerSetting = await OwnerSettings().loadSettings();
    log(
      "Loaded ownerEmail: ${_ownerSetting.ownerEmail}",
    ); // Get as per your app

    final snapshot = await FirebaseFirestore.instance
        .collection('Turf_Owner')
        .doc(_ownerSetting.ownerEmail)
        .collection('Worker')
        .doc(workerEmail)
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: '$year-$month-01')
        .where('date', isLessThanOrEqualTo: '$year-$month-31')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['date'] != null && data['status'] != null) {
        attendanceMap[data['date']] = data['status'];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int year = selectedMonth.year;
    int month = selectedMonth.month;
    int daysInMonth = DateUtils.getDaysInMonth(year, month);

    Map<int, String> attendanceData = {};
    for (int day = 1; day <= daysInMonth; day++) {
      String key =
          "${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      if (attendanceMap.containsKey(key)) {
        attendanceData[day] = attendanceMap[key]!;
      }
    }

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    selectedMonth = DateTime(year, month - 1);
                  }),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "${month.toString().padLeft(2, '0')}/$year",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    selectedMonth = DateTime(year, month + 1);
                  }),
                ),
              ],
            ),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              itemCount: daysInMonth,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemBuilder: (_, index) {
                int day = index + 1;
                String? status = attendanceData[day];
                Color color = status == 'Present'
                    ? const Color.fromARGB(255, 10, 242, 18)
                    : status == 'Absent'
                    ? const Color.fromARGB(255, 236, 23, 8)
                    : Colors.transparent;
                Color textColor = color == Colors.transparent
                    ? Colors.black
                    : Colors.white;
                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MarkAttendanceSheet extends StatefulWidget {
  final String workerEmail;
  const MarkAttendanceSheet({required this.workerEmail, Key? key})
    : super(key: key);
  @override
  _MarkAttendanceSheetState createState() => _MarkAttendanceSheetState();
}

class _MarkAttendanceSheetState extends State<MarkAttendanceSheet> {
  DateTime? _selectedDate;
  // ignore: unused_field
  String? _attendanceStatus;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mark Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(DateFormat('yyyy-MM-dd').format(_selectedDate!)),

              trailing: Icon(Icons.calendar_today),
              onTap: null, // disables the tap
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _selectedDate == null
                      ? null
                      : () async {
                          OwnerSettings _ownerSetting = await OwnerSettings()
                              .loadSettings();
                          log("Loaded ownerEmail: ${_ownerSetting.ownerEmail}");
                          final String key =
                              "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                          // Replace with the right Firestore path for your structure
                          await FirebaseFirestore.instance
                              .collection('Turf_Owner')
                              .doc(
                                _ownerSetting.ownerEmail,
                              ) // Get this from SharedPreferences or pass as param
                              .collection('Worker')
                              .doc(widget.workerEmail)
                              .collection('attendance')
                              .doc(key)
                              .set({'status': 'Present', 'date': key}, SetOptions(merge: true));

                          globalAttendanceMap[key] = 'Present';
                          attendanceMap[key] = 'Present';
                          Navigator.pop(context);
                        },
                  child: Text('Present'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 39, 226, 45),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedDate == null
                      ? null
                      : () async {
                          OwnerSettings _ownerSetting = await OwnerSettings()
                              .loadSettings();
                          log("Loaded ownerEmail: ${_ownerSetting.ownerEmail}");
                          final String key =
                              "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                          // Replace with the right Firestore path for your structure
                          await FirebaseFirestore.instance
                              .collection('Turf_Owner')
                              .doc(
                                _ownerSetting.ownerEmail,
                              ) // Get this from SharedPreferences or pass as param
                              .collection('Worker')
                              .doc(widget.workerEmail)
                              .collection('attendance')
                              .doc(key)
                              .set({'status': 'Absent', 'date': key}, SetOptions(merge: true));

                          globalAttendanceMap[key] = 'Absent';
                          attendanceMap[key] = 'Absent';
                          Navigator.pop(context);
                        },
                  child: Text('Absent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 242, 23, 8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
