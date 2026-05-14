import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/home(sport)/Bookings/Bookqr(sport).dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class User_Razorpay extends StatefulWidget {
  const User_Razorpay({super.key});

  @override
  _User_RazorpayState createState() => _User_RazorpayState();
}

class _User_RazorpayState extends State<User_Razorpay> {
  late Razorpay _razorpay;
  bool _navigated = false; // Prevent double navigation

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({required int amount}) {
    var options = {
      'key': 'rzp_test_RRLNbb21SHGawp',
      'amount': amount,
      'name': 'Demo Payment',
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
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BookQRSport(rawText: '', turfDetails: {},),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment failed: ${response.message}');
    // if (!_navigated) {
    //   _navigated = true;
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(
    //       builder: (_) => RazorSuccessPage(),
    //     ),
    //   );
    // }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('⚠️ External wallet selected: ${response.walletName}');
    // if (!_navigated) {
    //   _navigated = true;
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(
    //       builder: (_) => RazorSuccessPage(),
    //     ),
    //   );
    // }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Razorpay Integration Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => openCheckout(amount: 50000),
            child: const Text('Pay ₹500'),
          ),
        ),
      ),
    );
  }
}
