import 'package:flutter/material.dart';
import 'package:playz_user/View/worker_view/worker_drower.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedTurf = "CrossFit";

  final List<String> turfs = ["CrossFit", "GreenBox", "GreenChill"];

  final List<Map<String, String>> paymentHistory = [
    {
      "date": "Oct 26, 2023",
      "amount": "₹500.00",
      "turf": "CrossFit",
      "method": "Pending",
    },
    {
      "date": "Oct 18, 2023",
      "amount": "₹450.00",
      "turf": "GreenBox",
      "method": "Cash",
    },
    {
      "date": "Oct 10, 2023",
      "amount": "₹600.00",
      "turf": "GreenChill",
      "method": "UPI",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: WorkerDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Payment History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 240, 230, 225),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard(
                        "Total Earned",
                        "₹2858.00",
                        Colors.greenAccent,
                      ),
                      _buildSummaryCard("Pending", "₹500.00", Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Filter by Turf",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTurf,
                        isExpanded: true,
                        items: turfs
                            .map(
                              (turf) => DropdownMenuItem(
                                value: turf,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.sports_soccer,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      turf,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTurf = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: paymentHistory.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = paymentHistory[index];
                      return Card(
                        color: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[300],
                            child: const Icon(
                              Icons.payments,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item["date"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "${item["turf"]} • ${item["method"]}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            item["amount"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: 160,
      height: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
