import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/coach_home_screen.dart';
import 'package:playz_user/View/trainer_view/trainer_navigation.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
   Map<String, bool> days = {};
  String sessionType = "Regular Sessions";
  String selectedDay = "Select working days of sessions";
  final TextEditingController sessionTimeController = TextEditingController();
  final TextEditingController chargesController = TextEditingController();
  final TextEditingController upiController = TextEditingController();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.deepOrange),
          )
        ],
        title: const Text(
          "Sessions",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.deepOrange,
                    child: Text("1", style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                      child: Divider(color: Colors.deepOrange, thickness: 2)),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.deepOrange,
                    child: Text("2", style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                      child: Divider(color: Colors.deepOrange, thickness: 2)),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.deepOrange,
                    child: Text("3", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Select Session
              const Text(
                "Select Session",
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("One-Time Session"),
                      value: "One-Time Session",
                      groupValue: sessionType,
                      activeColor: Colors.deepOrange,
                      onChanged: (value) {
                        setState(() => sessionType = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Regular Sessions"),
                      value: "Regular Sessions",
                      groupValue: sessionType,
                      activeColor: Colors.deepOrange,
                      onChanged: (value) {
                        setState(() => sessionType = value!);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Select Days
              const Text(
                "Select Days",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      // Map to store day selection
                      days = {
                        "Monday": true,
                        "Tuesday": true,
                        "Wednesday": true,
                        "Thursday": true,
                        "Friday": true,
                        "Saturday": true,
                        "Sunday": true,
                      };

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text(
                                      "Select Days",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Days list
                                  ...days.keys.map((day) {
                                    return CheckboxListTile(
                                      title: Text(
                                        day,
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                      value: days[day],
                                      activeColor: Colors.deepOrange,
                                      checkColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.deepOrange,
                                        width: 2,
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      onChanged: (val) {
                                        setState(() {
                                          days[day] = val!;
                                        });
                                      },
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10),
                                  // Done button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Done",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Select working days of sessions",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.deepOrange),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Session Time
              const Text(
                "Session Time",
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: sessionTimeController,
                decoration: InputDecoration(
                  hintText: "Enter Session time and duration",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Session Charges
              const Text(
                "Session Charges",
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: chargesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Amount per month",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: const Icon(Icons.currency_rupee,
                      color: Colors.deepOrange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // UPI ID
              const Text(
                "UPI ID",
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: upiController,
                decoration: InputDecoration(
                  hintText: "UPI ID",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "UPI",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                     TrainerSettings trainerSettings = await TrainerSettings().loadSettings();

                    DocumentReference profileRef = _firestore.collection('Turf_Trainer').doc(trainerSettings.trainerEmail).collection('Trainer_Data').doc('Profile_Data');
                    await profileRef.update({
                      "session_charges":chargesController.text.trim(),
                      "session_days":days,
                      "session_time":sessionTimeController.text.trim(),
                      "sessions":sessionType,
                      "upi_id":upiController.text.trim()
                    });
                    // Next page navigation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  TrainerNavigation()),
                    );
                  },
                  child: const Text(
                    "NEXT",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}
