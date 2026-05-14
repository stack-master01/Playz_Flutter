
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playz_test/services/storage_service.dart';
import 'package:flutter_playz_test/services/notification_service.dart';

// ─── Palette ──────────────────────────────────────────────────────
const _kGradStart   = Color(0xFF6F6FAF);
const _kGradEnd     = Color(0xFF9A9FD3);
const _kBg          = Color(0xFFF3F2F7);
const _kCard        = Color(0xFFFFFFFF);
const _kField       = Color(0xFFE6E4EF);
const _kBtnGradStart= Color(0xFF6B6FAE);
const _kBtnGradEnd  = Color(0xFF8F95D6);
const _kTextPrimary = Color(0xFF2D2D2D);
const _kTextSecond  = Color(0xFF8A8A8A);
const _kAccent      = Color(0xFF6B6FAE);

class OtpDashboardTestScreen extends StatefulWidget {
  const OtpDashboardTestScreen({super.key});

  @override
  State<OtpDashboardTestScreen> createState() => _OtpDashboardTestScreenState();
}

class _OtpDashboardTestScreenState extends State<OtpDashboardTestScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _locationCtrl = TextEditingController();
  
  String? _generatedOtp;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _bookSlot() async {
    if (_selectedDate == null || _selectedTime == null || _locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all details')));
      return;
    }

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot book a slot in the past! Please select a valid future time.')),
      );
      return;
    }

    final otp = StorageService.userOtp;
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security issue: Fixed OTP missing. Please log out and re-login.')));
      return;
    }

    final dateStr = _formatDate(_selectedDate!);
    final timeStr = _selectedTime!.format(context);
    final turf = _locationCtrl.text.trim();
    final docId = "${dateStr}_$timeStr".replaceAll(' ', '_').replaceAll(',', '');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // AWAIT Firebase completion BEFORE revealing the secure string visually!
        await FirebaseFirestore.instance
            .collection('test_data')
            .doc(user.uid)
            .collection('slot_data')
            .doc(docId)
            .set({
          'date': dateStr,
          'time': timeStr,
          'turf': turf,
          'otp': otp,
        });
        
        // Render confident UI & triggers internally only upon confirmed network success
        setState(() {
          _generatedOtp = otp; 
        });
        NotificationService().showSlotBookedNotification(dateStr, timeStr, turf);

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot booked securely!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking network error: $e')));
        }
      }
    }
  }

  // Helper for formatting date like "Oct 24, 2023"
  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Verification',
            style: TextStyle(
              color: _kAccent,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildMainCard(),
              if (_generatedOtp != null) _buildOtpResult(),
              _buildSecurityBottomCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        gradient: LinearGradient(
          colors: [_kGradStart, _kGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 60),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate OTP',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select details to generate secure code',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('SELECT DATE'),
            const SizedBox(height: 8),
            _buildSelectableField(
              icon: Icons.calendar_today_rounded,
              placeholder: 'Oct 24, 2023',
              value: _selectedDate != null ? _formatDate(_selectedDate!) : null,
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),

            _buildFieldLabel('SELECT TIME'),
            const SizedBox(height: 8),
            _buildSelectableField(
              icon: Icons.access_time_rounded,
              placeholder: '14:30 PM',
              value: _selectedTime?.format(context),
              onTap: _pickTime,
            ),
            const SizedBox(height: 20),

            _buildFieldLabel('ENTER LOCATION'),
            const SizedBox(height: 8),
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: _kField,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_rounded, color: _kAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _locationCtrl,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'San Francisco, CA',
                        hintStyle: TextStyle(color: _kTextSecond, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // OTP Generation Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [_kBtnGradStart, _kBtnGradEnd],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _bookSlot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Book Slot & View Auto-OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: _kTextPrimary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSelectableField({
    required IconData icon,
    required String placeholder,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: _kField,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: _kAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              value ?? placeholder,
              style: TextStyle(
                color: value != null ? _kTextPrimary : _kTextSecond,
                fontSize: 16,
                fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashed OTP display area
  Widget _buildOtpResult() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(24),
          // Simulating a dashed border with a solid background and thin rim inside
        ),
        child: Column(
          children: [
            const Text(
              'YOUR SECURE CODE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _kTextPrimary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _generatedOtp!.split('').join('   '),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _kAccent,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Code expires in 05:00 minutes',
              style: TextStyle(
                fontSize: 12,
                color: _kTextSecond,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom info card
  Widget _buildSecurityBottomCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kField.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: _kField,
            radius: 20,
            child: Icon(Icons.security_rounded, color: _kAccent, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Level: High',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Encrypted end-to-end',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kTextSecond,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.info_outline, color: _kTextSecond, size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // 'Activity' tab active
        selectedItemColor: _kAccent,
        unselectedItemColor: _kTextSecond,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kField,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bar_chart_rounded, color: _kAccent),
            ),
            label: 'Activity',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
