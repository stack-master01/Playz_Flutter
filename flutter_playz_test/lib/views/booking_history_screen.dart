import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// ─── Palette ──────────────────────────────────────────────────────
const _kGradStart   = Color(0xFF4A3D88);
const _kGradEnd     = Color(0xFF8B81C3);
const _kBg          = Color(0xFFF3F0FB);
const _kCard        = Color(0xFFFFFFFF);
const _kField       = Color(0xFFECE9F5);
const _kTextPrimary = Color(0xFF2D2350);
const _kTextSecond  = Color(0xFFB0A8D0);
const _kAccent      = Color(0xFF5E50A0);

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch all slot_data docs for the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> _slotsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return FirebaseFirestore.instance
        .collection('test_data')
        .doc(uid)
        .collection('slot_data')
        .snapshots();
  }

  bool _isFuture(Map<String, dynamic> data) {
    try {
      final dateStr = data['date'] as String? ?? '';
      final timeStr = data['time'] as String? ?? '';
      // Try parsing "Oct 24, 2023" + "2:30 PM" style
      final combined = '$dateStr $timeStr';
      final parsed = DateFormat('MMM d, yyyy h:mm a').parseLoose(combined);
      return parsed.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _slotsStream(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final futureSlots =
                docs.where((d) => _isFuture(d.data())).toList();
            final pastSlots =
                docs.where((d) => !_isFuture(d.data())).toList();

            return Column(
              children: [
                _buildHeader(),
                _buildTabBar(
                    upcomingCount: futureSlots.length,
                    pastCount: pastSlots.length),
                Expanded(
                  child: () {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: _kAccent));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error loading bookings',
                              style: TextStyle(color: _kTextSecond)));
                    }
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSlotList(futureSlots, isUpcoming: true),
                        _buildSlotList(pastSlots, isUpcoming: false),
                      ],
                    );
                  }(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGradStart, _kGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(height: 20),
          const Text(
            'Booking History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'All your slot reservations in one place',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar({int upcomingCount = 0, int pastCount = 0}) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isUpcoming = _tabController.index == 0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Container(
            decoration: BoxDecoration(
              color: _kField,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                _tabPill(
                  label: 'Upcoming',
                  icon: Icons.event_available_rounded,
                  count: upcomingCount,
                  active: isUpcoming,
                  color: const Color(0xFF5E50A0),
                  onTap: () => _tabController.animateTo(0),
                ),
                const SizedBox(width: 6),
                _tabPill(
                  label: 'Past',
                  icon: Icons.history_rounded,
                  count: pastCount,
                  active: !isUpcoming,
                  color: const Color(0xFF9C8FD4),
                  onTap: () => _tabController.animateTo(1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabPill({
    required String label,
    required IconData icon,
    required int count,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? Colors.white : _kTextSecond,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : _kTextSecond,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> slots,
      {required bool isUpcoming}) {
    if (slots.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final data = slots[index].data();
        return _SlotCard(data: data, isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kField,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUpcoming ? Icons.event_available_rounded : Icons.history_rounded,
              color: _kAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isUpcoming ? 'No upcoming bookings' : 'No past bookings',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'Book a slot to get started!'
                : 'Your completed bookings will appear here.',
            style: const TextStyle(fontSize: 14, color: _kTextSecond),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Individual Slot Card ─────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isUpcoming;

  const _SlotCard({required this.data, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final date  = data['date']  as String? ?? '—';
    final time  = data['time']  as String? ?? '—';
    final turf  = data['turf']  as String? ?? '—';
    final otp   = data['otp']   as String? ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isUpcoming
              ? _kAccent.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? _kAccent.withValues(alpha: 0.1)
                        : _kField,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUpcoming
                        ? Icons.event_note_rounded
                        : Icons.history_rounded,
                    color: isUpcoming ? _kAccent : _kTextSecond,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turf,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? _kAccent.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUpcoming ? 'UPCOMING' : 'COMPLETED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isUpcoming ? _kAccent : _kTextSecond,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF0EDF8)),
            const SizedBox(height: 14),

            // Info rows
            _infoRow(Icons.calendar_today_rounded, 'Date', date),
            const SizedBox(height: 10),
            _infoRow(Icons.access_time_rounded, 'Time', time),
            const SizedBox(height: 14),

            // OTP chip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _kField,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, size: 18, color: _kAccent),
                  const SizedBox(width: 10),
                  const Text(
                    'Your OTP: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: _kTextSecond,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    otp.split('').join(' '),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kAccent,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kTextSecond),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: _kTextSecond),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
