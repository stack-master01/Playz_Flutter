import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ Added
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/profile.dart';
import 'package:playz_user/View/worker_view/worker_Details_skill_page.dart';

class WorkerCre_ProfilePage extends StatefulWidget {
  const WorkerCre_ProfilePage({super.key});

  @override
  State<WorkerCre_ProfilePage> createState() =>
      _workersCre_ProfileScreenState();
}

class _workersCre_ProfileScreenState extends State<WorkerCre_ProfilePage> {
  FirebaseFirestore firestoreobj = FirebaseFirestore.instance;

  TextEditingController workerNameController = TextEditingController();
  TextEditingController workerSurnameController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();

  String? selectedValue = "Male";
  XFile? _selectedImage;

  // ✅ Image upload function
  Future<String?> _uploadImageToFirebase(XFile image) async {
    try {
      String fileName =
          "worker_profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("worker_profiles")
          .child(fileName);
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

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
        height: screenHeight,
        width: screenWidth,
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
              padding: EdgeInsets.symmetric(horizontal: w(30), vertical: h(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: h(10)),
                  Text(
                    "Create your Profile",
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
                            radius: w(25),
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
                          color: Colors.grey,
                        ),
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: w(18),
                            backgroundColor: Colors.grey,
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
                            radius: w(18),
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
                  TextField(
                    controller: workerNameController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.person_outlined,
                        color: const Color.fromARGB(255, 109, 77, 65),
                        size: w(22),
                      ),
                      labelText: "Name",
                      labelStyle: TextStyle(fontSize: w(15)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(20)),
                      ),
                    ),
                    style: TextStyle(fontSize: w(15)),
                  ),
                  SizedBox(height: h(20)),
                  TextField(
                    controller: workerSurnameController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.person_outlined,
                        color: const Color.fromARGB(255, 109, 77, 65),
                        size: w(22),
                      ),
                      labelText: "Surname",
                      labelStyle: TextStyle(fontSize: w(15)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(20)),
                      ),
                    ),
                    style: TextStyle(fontSize: w(15)),
                  ),
                  SizedBox(height: h(10)),
                  Row(
                    children: [
                      SizedBox(width: w(10)),
                      Text("Date of Birth", style: TextStyle(fontSize: w(15))),
                    ],
                  ),
                  SizedBox(height: h(1)),
                  TextField(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1980),
                        lastDate: DateTime(2026),
                      );
                      String strDate = DateFormat.yMMMMd().format(pickedDate!);
                      birthdateController.text = strDate;
                    },
                    controller: birthdateController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(20)),
                      ),
                      hintText: "Select Date",
                      hintStyle: TextStyle(fontSize: w(15)),
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        size: w(22),
                      ),
                    ),
                    style: TextStyle(fontSize: w(15)),
                  ),
                  SizedBox(height: h(10)),
                  Row(
                    children: [
                      SizedBox(width: w(10)),
                      Text("Select Gender", style: TextStyle(fontSize: w(15))),
                    ],
                  ),
                  SizedBox(height: h(1)),
                  Container(
                    width: w(328),
                    height: h(55),
                    padding: EdgeInsets.symmetric(horizontal: w(12)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w(20)),
                      border: Border.all(
                        color: Color.fromARGB(255, 109, 77, 65),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        items: [
                          DropdownMenuItem(
                            value: "Male",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.male,
                                  color: Colors.blue,
                                  size: w(20),
                                ),
                                SizedBox(width: w(8)),
                                Text(
                                  "Male",
                                  style: TextStyle(
                                    fontSize: w(15),
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Female",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.female,
                                  color: Colors.pink,
                                  size: w(20),
                                ),
                                SizedBox(width: w(8)),
                                Text(
                                  "Female",
                                  style: TextStyle(
                                    fontSize: w(15),
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value!;
                          });
                        },
                        style: TextStyle(fontSize: w(15)),
                      ),
                    ),
                  ),
                  SizedBox(height: h(10)),
                  Row(
                    children: [
                      SizedBox(width: w(10)),
                      Text("Profile image", style: TextStyle(fontSize: w(15))),
                    ],
                  ),
                  SizedBox(height: h(1)),
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
                                    "Tap to upload image",
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
                  SizedBox(
                    width: w(388),
                    height: h(60),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          WorkerSettings workerobj = await WorkerSettings()
                              .loadSettings();
                          DocumentReference documentReferenceworker =
                              firestoreobj
                                  .collection("Turf_Worker")
                                  .doc(workerobj.email)
                                  .collection("Worker_Data")
                                  .doc("Profile_Data");

                          // ✅ Upload image first
                          String? imageUrl;
                          if (_selectedImage != null) {
                            imageUrl = await _uploadImageToFirebase(
                              _selectedImage!,
                            );
                          }

                          await documentReferenceworker.update({
                            "DOB": birthdateController.text.trim(),
                            "worker_gender": selectedValue,
                            "worker_name": workerNameController.text.trim(),
                            "worker_surname": workerSurnameController.text
                                .trim(),
                            if (imageUrl != null) "profile_image": imageUrl,
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WorkerDetailsSkillPage(),
                            ),
                          );
                        } catch (e) {
                          print("Error saving data: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Error saving profile. Please try again.",
                              ),
                            ),
                          );
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
