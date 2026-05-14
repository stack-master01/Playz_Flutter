import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/profile.dart';
import 'package:playz_user/View/worker_view/worker_verification_page.dart';

class WorkerDetailsSkillPage extends StatefulWidget {
  const WorkerDetailsSkillPage({super.key});

  @override
  State<WorkerDetailsSkillPage> createState() => _workerDetailsScreenState();
}

class _workerDetailsScreenState extends State<WorkerDetailsSkillPage> {
  FirebaseFirestore firebaseFirestoreworker = FirebaseFirestore.instance;

  bool isCheckedClean = false;
  bool isCheckedGuard = false;
  bool isCheckedmain = false;
  bool isCheckedpark = false;
  bool isCheckedrepo = false;
  bool isCheckedrefee = false;
  bool isCheckedassi = false;

  String? selectedValue;

  final List<String> options = [
    "  Full-Time",
    "  Part-Time",
    "  Weekends-only",
    "  Per-Day",
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    double w(double val) => screenWidth * (val / 428);
    double h(double val) => screenHeight * (val / 926);

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w(18), vertical: h(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: h(10)),
                  Text(
                    "Details and Skills",
                    style: TextStyle(
                      fontSize: w(28),
                      fontWeight: FontWeight.w700,
                      color: const Color.fromARGB(255, 109, 77, 65),
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: h(18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: w(20),
                            backgroundColor: Color.fromRGBO(91, 61, 59, 1),
                            child: Text(
                              "1",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: w(18),
                              ),
                            ),
                          ),
                          SizedBox(height: h(6)),
                          Text("Stage 1", style: TextStyle(fontSize: w(13))),
                        ],
                      ),
                      Transform.translate(
                        offset: Offset(0, -h(12)),
                        child: Container(
                          width: w(50),
                          height: h(2),
                          color: Color.fromRGBO(91, 61, 59, 1),
                        ),
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: w(28),
                            backgroundColor: Color.fromRGBO(91, 61, 59, 1),
                            child: Text(
                              "2",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: w(18),
                              ),
                            ),
                          ),
                          SizedBox(height: h(6)),
                          Text("Stage 2", style: TextStyle(fontSize: w(13))),
                        ],
                      ),
                      Transform.translate(
                        offset: Offset(0, -h(12)),
                        child: Container(
                          width: w(50),
                          height: h(2),
                          color: Colors.grey,
                        ),
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: w(20),
                            backgroundColor: Colors.grey,
                            child: Text(
                              "3",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: w(18),
                              ),
                            ),
                          ),
                          SizedBox(height: h(6)),
                          Text("Stage 3", style: TextStyle(fontSize: w(13))),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: h(28)),
                  Row(
                    children: [
                      SizedBox(width: w(10)),
                      Text(
                        "Select Skills",
                        style: TextStyle(
                          color: Color.fromARGB(255, 109, 77, 65),
                          fontSize: w(22),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h(10)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: h(8),
                      horizontal: w(8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(w(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isCheckedClean,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedClean = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Cleaning Staff",
                              style: TextStyle(fontSize: w(16)),
                            ),
                            Checkbox(
                              value: isCheckedmain,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedmain = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Maintenance Staff",
                              style: TextStyle(fontSize: w(16)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: isCheckedGuard,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedGuard = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Security Guard",
                              style: TextStyle(fontSize: w(16)),
                            ),
                            Checkbox(
                              value: isCheckedpark,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedpark = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Parking Attendant",
                              style: TextStyle(fontSize: w(16)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: isCheckedrepo,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedrepo = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Receptionist   ",
                              style: TextStyle(fontSize: w(16)),
                            ),
                            Checkbox(
                              value: isCheckedrefee,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedrefee = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Referee / Umpire  ",
                              style: TextStyle(fontSize: w(16)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: isCheckedassi,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedassi = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Medical Assistant",
                              style: TextStyle(fontSize: w(16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h(28)),
                  Row(
                    children: [
                      SizedBox(width: w(10)),
                      Text(
                        "Select Work Type",
                        style: TextStyle(
                          color: Color.fromARGB(255, 109, 77, 65),
                          fontSize: w(22),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h(10)),
                  Container(
                    width: w(328),
                    height: h(55),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 109, 77, 65),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(w(20)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(
                          "  Select an option",
                          style: TextStyle(
                            fontSize: w(16),
                            color: Colors.black,
                          ),
                        ),
                        value: selectedValue,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue;
                          });
                        },
                        items: options.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: w(16),
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(fontSize: w(16)),
                      ),
                    ),
                  ),
                  SizedBox(height: h(80)),

                  // ✅ Modified "Next" button
                  SizedBox(
                    width: w(388),
                    height: h(60),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Collect selected skills
                          List<String> selectedSkills = [];

                          if (isCheckedClean) selectedSkills.add("cleaning");
                          if (isCheckedGuard) selectedSkills.add("security");
                          if (isCheckedmain) selectedSkills.add("maintenance");
                          if (isCheckedpark) selectedSkills.add("parking");
                          if (isCheckedrepo) selectedSkills.add("reception");
                          if (isCheckedrefee) selectedSkills.add("referee");
                          if (isCheckedassi) selectedSkills.add("medical");

                          // Get current worker email
                          WorkerSettings workerobj = await WorkerSettings()
                              .loadSettings();

                          // Firestore reference
                          DocumentReference documentReferenceworker =
                              firebaseFirestoreworker
                                  .collection("Turf_Worker")
                                  .doc(workerobj.email)
                                  .collection("Worker_Data")
                                  .doc("Profile_Data");

                          // Update Firestore with skills array + work_type
                          await documentReferenceworker.update({
                            "skills": selectedSkills,
                            "work_type": selectedValue?.trim(),
                          });

                          debugPrint(
                            "✅ Skills and work type updated successfully!",
                          );

                          // Navigate to next page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WorkerverificationPage(),
                            ),
                          );
                        } catch (e) {
                          debugPrint("❌ Error updating Firestore: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 109, 77, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w(20)),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black38,
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: w(20),
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h(18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
