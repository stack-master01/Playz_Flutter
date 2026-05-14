import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/worker_view/worker_navigator_page.dart';

class WorkerverificationPage extends StatefulWidget {
  const WorkerverificationPage({super.key});

  @override
  State<WorkerverificationPage> createState() => _workersverificationState();
}

class _workersverificationState extends State<WorkerverificationPage> {
  FirebaseFirestore firebaseFirestoreworker = FirebaseFirestore.instance;

  TextEditingController UPI_IDController = TextEditingController();

  XFile? _selectedImage;

  Future<void> _pickImage() async {
    // ✅ Request permission
    var status = await Permission.mediaLibrary.isGranted; // For gallery
    if (status) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission denied. Please allow gallery access."),
        ),
      );
    }
  }

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
                    "Verification",
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
                            radius: w(20),
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
                          color: Color.fromRGBO(91, 61, 59, 1),
                        ),
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: w(28),
                            backgroundColor: Color.fromRGBO(91, 61, 59, 1),
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
                      Text("Uplode Gov.ID", style: TextStyle(fontSize: w(16))),
                    ],
                  ),
                  SizedBox(height: h(8)),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: h(150),
                      width: w(328),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(w(10)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _selectedImage == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: w(40),
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: h(8)),
                                  Text(
                                    "Tap to uplode image",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: w(15),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(w(10)),
                              child: Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: h(20)),
                  TextField(
                    controller: UPI_IDController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.payment_outlined,
                        color: const Color.fromARGB(255, 109, 77, 65),
                        size: w(22),
                      ),
                      labelText: "UPI ID",
                      labelStyle: TextStyle(fontSize: w(15)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(20)),
                      ),
                    ),
                    style: TextStyle(fontSize: w(15)),
                  ),
                  SizedBox(height: h(80)),
                  SizedBox(
                    width: w(388),
                    height: h(60),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          WorkerSettings workerobj = await WorkerSettings()
                              .loadSettings();
                          DocumentReference documentReferenceworker =
                              firebaseFirestoreworker
                                  .collection("Turf_Worker")
                                  .doc(workerobj.email)
                                  .collection("Worker_Data")
                                  .doc("Profile_Data");
                          await documentReferenceworker.update({
                            "worker_upi_id": UPI_IDController.text.trim(),
                            "id_proof_url": "",
                          });
                        } catch (e) {}
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WorkernavigatorPage(),
                          ),
                        );
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
