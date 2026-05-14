import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_playz_test/views/dashboard_screen.dart';
import 'package:flutter_playz_test/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Palette (matches signup screen exactly) ──────────────────────
const _kGradStart   = Color(0xFF4A3D88);
const _kGradEnd     = Color(0xFF8B81C3);
const _kBg          = Color(0xFFF3F0FB);
const _kCard        = Color(0xFFFFFFFF);
const _kBox         = Color(0xFFECE9F5);
const _kTextPrimary = Color(0xFF2D2350);
const _kTextSecond  = Color(0xFFB0A8D0);
const _kAccent      = Color(0xFF5E50A0);
const _kError       = Color(0xFFE05A5A);

const int _otpLength = 6;
const int _resendSeconds = 30;

// ─── OTP Verification Screen ──────────────────────────────────────
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    this.phoneNumber = '',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  // Controllers & focus nodes for each OTP digit
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _hasError    = false;
  bool _isLoading   = false;
  int  _countdown   = _resendSeconds;
  bool _canResend   = false;
  Timer? _timer;

  // Slide-in animation
  late AnimationController _animCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();

    _startCountdown();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNodes[0].requestFocus());
  }

  void _startCountdown() {
    setState(() {
      _countdown = _resendSeconds;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    setState(() => _hasError = false);

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-verify when all boxes filled
    if (_otp.length == _otpLength) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _onVerify() async {
    if (_otp.length < 6) {
      setState(() => _hasError = true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Hydrate via user controller with the verified phone number
      await Get.find<UserController>().setUser(phone: widget.phoneNumber);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged in!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      setState(() => _hasError = true);
    }

    setState(() => _isLoading = false);
  }

  void _onResend() {
    if (!_canResend) return;
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
    setState(() => _hasError = false);
    _startCountdown();
    debugPrint('OTP resent');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: _buildCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 52,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGradStart, _kGradEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back arrow
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Title & subtitle centered
          Center(
            child: Column(
              children: [
                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Code sent to ${widget.phoneNumber}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating white card ──────────────────────────────────────────
  Widget _buildCard() {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _kGradStart.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // OTP boxes
            _buildOtpRow(),
            if (_hasError) ...[
              const SizedBox(height: 10),
              const Text(
                'Invalid code. Please try again.',
                style: TextStyle(
                  color: _kError,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 28),
            // Verify button
            _buildVerifyButton(),
            const SizedBox(height: 24),
            // Resend section
            _buildResend(),
          ],
        ),
      ),
    );
  }

  // ── 6 OTP boxes in a row ─────────────────────────────────────────
  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) => _OtpBox(
        controller: _controllers[i],
        focusNode: _focusNodes[i],
        hasError: _hasError,
        onChanged: (v) => _onChanged(v, i),
        onKeyEvent: (e) => _onKeyEvent(e, i),
      )),
    );
  }

  // ── Verify button ────────────────────────────────────────────────
  Widget _buildVerifyButton() {
    return _GradientButton(
      label: 'Verify',
      isLoading: _isLoading,
      onTap: _onVerify,
    );
  }

  // ── Resend section ───────────────────────────────────────────────
  Widget _buildResend() {
    return Column(
      children: [
        Text(
          "Didn't receive code?",
          style: const TextStyle(
            color: _kTextSecond,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _onResend,
          child: _canResend
              ? const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: _kAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Resend OTP ',
                        style: TextStyle(
                          color: _kTextSecond,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '${_countdown}s',
                        style: const TextStyle(
                          color: _kAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Single OTP Box ───────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 52,
        decoration: BoxDecoration(
          color: hasError ? _kError.withValues(alpha: 0.08) : _kBox,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? _kError.withValues(alpha: 0.6)
                : focusNode.hasFocus
                    ? _kAccent.withValues(alpha: 0.6)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          obscureText: true,
          obscuringCharacter: '•',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: hasError ? _kError : _kTextPrimary,
            height: 1,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Verify Button ───────────────────────────────────────
class _GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.label, required this.isLoading, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGradStart, _kGradEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: _kGradStart.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
