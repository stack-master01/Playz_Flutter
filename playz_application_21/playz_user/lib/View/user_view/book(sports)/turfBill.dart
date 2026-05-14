import 'dart:developer'; // Required for log()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/User_Controller/User_Upload_Booking_Controller.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/book(sports)/user_qr_after_payment.dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../menu(sport)/menu(sport).dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class TurfBill extends StatefulWidget {
  Map<String, dynamic> bookingDetails = {};
  Map<String,dynamic> currentTurfInfo = {};
  TurfBill({super.key, required this.bookingDetails,required this.currentTurfInfo});

  @override
  State<TurfBill> createState() => _TurfBillState();
}

class _TurfBillState extends State<TurfBill> {
  Map<String, dynamic> currentBookingDetails = {};

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Bill Details",
      "Cricket",
      "Mon, 01-09-2025",
      "5:00 AM - 7:00 AM",
      "Slot Price",
      "INR 2000",
      "Convenience Fee",
      "INR 20.00",
      "Redeem Z-coins",
      "- INR 200",
      "Total Amount",
      "Booking Policies",
      "Booking & Payment:",
      "Slots must be booked in advance.",
      "50% advance required to confirm. Balance to be cleared before play.",
      "Cancellation:",
      "Cancel 48 hrs before → Full refund/reschedule.",
      "Cancel 24 hrs before → 50% refund.",
      "Cancel within 24 hrs → No refund.",
      "Timings:",
      "Each slot = 60 minutes (includes setup & wrap-up).",
      "Late arrivals won’t get extra time.",
      "Footwear & Equipment:",
      "Only non-studded turf shoes allowed.",
      "Players must bring their own gear.",
      "Conduct:",
      "No smoking, alcohol, or abusive behavior.",
      "Respect staff, players, and property.",
      "Cleanliness & Care:",
      "Use dustbins, keep turf clean.",
      "Damages will be charged.",
      "Safety:",
      "Play at your own risk. Management not responsible for injuries or lost items.",
      "PAY INR 2000", // Payment button text
      // END: Add default english text here
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }
    return keys.toList();
  }

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = await getTranslatedText(
        key,
        lang,
      ); // Must be defined in your project
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _languageChangeListener() {
    _loadTranslations(appLanguageNotifier.value);
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await ThemeSettings(
      theme: null,
    ).loadSelectedTheme();
    appSettingsNotifier.value = ThemeSettings(theme: selectedTheme);
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await ThemeSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    appLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) => _translationsCache[key] ?? key;
  // ------------------------------------------------------------------

  String? selectedLocation;

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
  }

  // ===================================================================
  String? currentUserEmail;
    String? currentUserName;

  Future<void> loadUserEmail() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUserEmail = userSettings.email;
    currentUserName = userSettings.userName;
    log("shared email: $currentUserEmail");
    log("shared name: $currentUserName");
     qrCodeText = "${currentUserEmail}_${DateTime.now()}";
    log(qrCodeText);
  }


  late Razorpay _razorpay;
  bool _navigated = false; // Prevent double navigation

  void openCheckout({required double amount}) {
    var options = {
      'key': 'rzp_test_RRLNbb21SHGawp',
      'amount': amount,
      'name': _getTranslation(
        'Booking Payment',
      ), // Use translated text if needed
      'description': _getTranslation(
        'Test transaction',
      ), // Use translated text if needed
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

  String qrCodeText = "";
 
 Future<void> uploadQRToUser() async {
  UserSettings userSettings = await UserSettings().loadSettings();
  log("User Email: ${userSettings.email}");
  try {
    double totalPayable = _computeTotalPayable();
    await _firestore
        .collection("Turf_User")
        .doc(userSettings.email)
        .collection("User_Data")
        .doc("User_Bookings")
        .collection("All_Bookings")
        .doc()
        .set({
      "day_date": "${currentBookingDetails['dayOfWeek']} | ${currentBookingDetails['selectedDate']}",
      "qr_text": qrCodeText,
      // store the payable amount (after z-coin discount and convenience fee)
      "slot_price": "${totalPayable}",
      "slot_time": "${currentBookingDetails['startTime']} - ${currentBookingDetails['endTime']}",
      "turf_location": widget.currentTurfInfo['location']['address'],
      "turf_name": widget.currentTurfInfo['turfName'],
      "sport": currentBookingDetails['selectedSport']
    });
  } on FirebaseFirestore catch (e) {
    log("Error: $e");
  }
 }

  // -------------------------
  // PRICE CALC HELPERS
  // -------------------------
  double _getBasePrice() {
    final tp = currentBookingDetails['totalPrice'];
    if (tp is num) return tp.toDouble();
    return double.tryParse(tp?.toString() ?? '') ?? 0.0;
  }

  double _computeDiscountedPrice() {
    double base = _getBasePrice();
    double redeem = isOn ? 200.0 : 0.0;
    if (redeem > base) redeem = base; // don't allow negative
    return base - redeem;
  }

  double _computeConvenienceFee() => _computeDiscountedPrice() * 0.02;

  double _computeTotalPayable() => _computeDiscountedPrice() + _computeConvenienceFee();

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment success with ID: ${response.paymentId}');
    if (!_navigated) {
      _navigated = true;
log("${currentBookingDetails}");
  widget.currentTurfInfo['day_date'] = "${currentBookingDetails['dayOfWeek']} | ${currentBookingDetails['selectedDate']}";
  widget.currentTurfInfo['time'] = "${currentBookingDetails['startTime']} - ${currentBookingDetails['endTime']}";
  widget.currentTurfInfo['price'] = "${_computeTotalPayable().toStringAsFixed(2)}";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => User_QR_Paid(rawText: '${qrCodeText}', turfDetails: widget.currentTurfInfo,),
        ),
      );

      Map<String, dynamic>
      bookDataObj = UserSendBookingController().createBookingObject(
        day_date:
            "${currentBookingDetails['dayOfWeek']} | ${currentBookingDetails['selectedDate']}",
        payment_status: "Paid",
        qr_code_text: qrCodeText,
        sport: currentBookingDetails['selectedSport'],
        time:
            "${currentBookingDetails['startTime']} - ${currentBookingDetails['endTime']}",
        user_name: "$currentUserName",
      );
      UserSendBookingController().uploadUserBooking(
        bookDataObj,
        currentBookingDetails['turfInfo']['userEmail'],
        currentBookingDetails['turfInfo']['turfID'],
      );

      uploadQRToUser();
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
    loadUserEmail();
    
    currentBookingDetails = widget.bookingDetails;
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // 🌍 Translation Logic Initialization
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    appLanguageNotifier.addListener(_languageChangeListener);
    // Razorpay Initialization
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    if (mounted) {
    // Call setState to rebuild the widget (if needed) and generate QR code text
    setState(() {
    });
  }
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(
      _languageChangeListener,
    ); // 🌍 Translation Logic Disposal
    _razorpay.clear();
    super.dispose();
  }

  double _dragPosition = 0; // Track drag position
  double _maxDrag = 300; // Width - icon size (adjust to your button width)
  bool isOn = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isRookieSelected = false;
  bool isContenderSelected = false;
  bool isEliteSelected = false;
  bool isChampionSelected = false;
  bool isGOATSelected = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
  bool isDark = settings.theme == "Dark";
  // compute pricing values taking into account z-coin redemption
  double basePrice = _getBasePrice();
  double convenienceFee = _computeConvenienceFee();
  double totalPayable = _computeTotalPayable();
  return Scaffold(
          body: Stack(
            // Stack is used to overlap top header and white sheet
            children: [
              // 🔹 Green header background
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),

                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 🔙 Back button
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: Reusable.getDeviceWidth(context, W: 25),
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            SizedBox(width: 5),
                            // 🔹 Title text
                            Text(
                              _getTranslation("Bill Details"), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 White rounded bottom sheet (Main content area)
              Positioned(
                top:
                    (MediaQuery.of(context).size.height) *
                    0.097192, // pushes down from top
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Reusable.getDeviceWidth(context, W: 20),
                      right: Reusable.getDeviceWidth(context, W: 20),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 10),
                              ),
                              child: Text(
                                _getTranslation(
                                  currentBookingDetails['selectedSport'],
                                ), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 10),
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: Reusable.getDeviceWidth(context, W: 30),
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                              ),
                              SizedBox(
                                width: Reusable.getDeviceWidth(context, W: 5),
                              ),
                              Text(
                                _getTranslation(
                                  "${currentBookingDetails['dayOfWeek']}, ${currentBookingDetails['selectedDate']}",
                                ), // 🌍 Translated (Date should be dynamic, but translating the static string)
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 5),
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: Reusable.getDeviceWidth(context, W: 30),
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                              ),
                              SizedBox(
                                width: Reusable.getDeviceWidth(context, W: 5),
                              ),
                              Text(
                                _getTranslation(
                                  "${currentBookingDetails['startTime']} - ${currentBookingDetails['endTime']}",
                                ), // 🌍 Translated (Time should be dynamic, but translating the static string)
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 5),
                          ),

                          Divider(
                            color: isDark
                                ? Reusable.getTextGrey()
                                : const Color.fromRGBO(81, 81, 81, 0.3),
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 5),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _getTranslation("Bill Details"), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getBlack(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 10),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTranslation("Slot Price"), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),

                              Text(
                                _getTranslation(
                                  "INR ${basePrice.toStringAsFixed(2)}",
                                ), // 🌍 Translated (Price)
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 5),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTranslation(
                                  "Convenience Fee",
                                ), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),

                              Text(
                                _getTranslation(
                                  "INR ${convenienceFee.toStringAsFixed(2)}",
                                ), // 🌍 Translated (Fee)
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 0),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTranslation(
                                  "Redeem Z-coins",
                                ), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),

                              Switch(
                                activeTrackColor: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                activeColor: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                                inactiveThumbColor: isDark
                                    ? Reusable.getDarkModeGrey()
                                    : Reusable.getDarkGrey(),
                                inactiveTrackColor: isDark
                                    ? Reusable.getTextGrey()
                                    : Reusable.getLightGrey(),
                                value: isOn,
                                onChanged: (bool value) {
                                  setState(() {
                                    isOn = value; // update toggle state
                                  });
                                },
                              ),
                            ],
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: isOn
                                ? Text(
                                    _getTranslation(
                                      "- INR 200",
                                    ), // 🌍 Translated (Redemption amount)
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(255, 0, 0, 1),
                                    ),
                                  )
                                : const SizedBox(),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 30),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTranslation(
                                  "Total Amount",
                                ), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getBlack(),
                                ),
                              ),

                              Text(
                                _getTranslation(
                                  "INR ${totalPayable.toStringAsFixed(2)}",
                                ), // 🌍 Translated (Total)
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getBlack(),
                                ),
                              ),
                            ],
                          ),

                          Divider(
                            color: isDark
                                ? Reusable.getTextGrey()
                                : const Color.fromRGBO(81, 81, 81, 0.3),
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 5),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _getTranslation(
                                "Booking Policies",
                              ), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getBlack(),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 10),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getBlack(),
                                ),
                                children: [
                                  // Translated policy sections
                                  TextSpan(
                                    text:
                                        _getTranslation("Booking & Payment:") +
                                        '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Slots must be booked in advance.",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "50% advance required to confirm. Balance to be cleared before play.",
                                        ) +
                                        '\n\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation("Cancellation:") + '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Cancel 48 hrs before → Full refund/reschedule.",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Cancel 24 hrs before → 50% refund.",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Cancel within 24 hrs → No refund.",
                                        ) +
                                        '\n\n',
                                  ),
                                  TextSpan(
                                    text: _getTranslation("Timings:") + '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Each slot = 60 minutes (includes setup & wrap-up).",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Late arrivals won’t get extra time.",
                                        ) +
                                        '\n\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Footwear & Equipment:",
                                        ) +
                                        '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Only non-studded turf shoes allowed.",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Players must bring their own gear.",
                                        ) +
                                        '\n\n',
                                  ),
                                  TextSpan(
                                    text: _getTranslation("Conduct:") + '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "No smoking, alcohol, or abusive behavior.",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Respect staff, players, and property.",
                                        ) +
                                        '\n\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation("Cleanliness & Care:") +
                                        '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Use dustbins, keep turf clean.",
                                        ) +
                                        '\n',
                                  ),
                                  TextSpan(
                                    text:
                                        _getTranslation(
                                          "Damages will be charged.",
                                        ) +
                                        '\n\n',
                                  ),
                                  TextSpan(
                                    text: _getTranslation("Safety:") + '\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _getTranslation(
                                      "Play at your own risk. Management not responsible for injuries or lost items.",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 30),
                          ),
                          GestureDetector(
                            // onTap: () {
                            //   openCheckout(amount: 50000);
                            // },
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 60,
                                width: 350,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Center Text
                                    Text(
                                      _getTranslation("PAY INR ${totalPayable.toStringAsFixed(2)}"),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                      ),
                                    ),

                                    // Draggable Icon
                                    Positioned(
                                      left: _dragPosition,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          setState(() {
                                            // update drag but keep inside bounds
                                            _dragPosition += details.delta.dx;
                                            if (_dragPosition < 0)
                                              _dragPosition = 0;
                                            if (_dragPosition > _maxDrag)
                                              _dragPosition = _maxDrag;
                                          });
                                        },
                                        onHorizontalDragEnd: (details) {
                                          // Check if dragged far enough
                                          if (_dragPosition > _maxDrag * 0.7) {
                                            // amount expected in paise for Razorpay (INR * 100)
                                            openCheckout(amount: (_computeTotalPayable() * 100));
                                          }

                                          // Reset position if not swiped enough
                                          setState(() {
                                            _dragPosition = 0;
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: Reusable.getDeviceWidth(
                                              context,
                                              W: 5,
                                            ),
                                          ),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getGreen(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: UserLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}
