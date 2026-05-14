import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_TurfRegister_Controller.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_Turf_Edit_Details_Controller.dart';
import 'package:playz_user/View/owner_view/TurfDetails_Screen.dart';

class ownerRegisterTurfScreen extends StatefulWidget {
  final String? email_ID;
  final bool doEdit;
  String turfName;

  ownerRegisterTurfScreen({
    this.doEdit = false,
    required this.email_ID,
    super.key,
    this.turfName = "",
  });

  @override
  State<ownerRegisterTurfScreen> createState() => _ownerRegisterTurfScreenState();
}

class _ownerRegisterTurfScreenState extends State<ownerRegisterTurfScreen> {
  
  TextEditingController ownerTurfName = TextEditingController();
  TextEditingController ownerTurfDescription = TextEditingController();
  int currentStep = 1;
  Widget _buildStep(int step) {
    bool isActive = step == currentStep;
    bool isCompleted = step < currentStep;

    return CircleAvatar(
      radius: 20,
      backgroundColor: isActive
          ? Color.fromRGBO(13, 71, 161, 1)
          : isCompleted
          ? Colors.green
          : Colors.grey[300],
      child: Text(
        "$step",
        style: TextStyle(
          color: isActive || isCompleted ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Line between steps
  Widget _buildLine() {
    return SizedBox(
      width: 130,
      child: Divider(color: Colors.grey, thickness: 4),
    );
  }

  //image picker
  final List<XFile> _images = [];
  List<dynamic> _fetchedImages = [];

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? picked = await picker.pickMultiImage();
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      doEdit ? _fetchedImages.removeAt(index) : _images.removeAt(index);
    });
  }

  //controller helper
  List<String> downloadUrls = [];
  final OwnerRegisterController _ownerRegisterController =
      OwnerRegisterController();
  bool doEdit = false;
  void initState() {
    super.initState();
    if (widget.doEdit) {
      doEdit = widget.doEdit;
      ownerTurfName.text = widget.turfName;
      loadTurfData(widget.turfName);
    }
  }

  Map<String, dynamic> fetchedData = {};
  Future<void> loadTurfData(String turfName) async {
    final turfData = await EditTurfDataController().fetchTurfData(
      turfName: turfName,
    );
    fetchedData = turfData[0];
    log("fetched turf data to edit: ${fetchedData}");
    ownerTurfDescription.text = fetchedData['turfDescription'];
    _fetchedImages = fetchedData['turfImages'];
    log("fetched images: ${_fetchedImages}");
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    String email = widget.email_ID ?? "";
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Register Your Turf",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(13, 71, 161, 1),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Color.fromRGBO(13, 71, 161, 1),
                            size: 29,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _buildStep(1),
                        _buildLine(),
                        _buildStep(2),
                        _buildLine(),
                        _buildStep(3),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Turf Name",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 388,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(237, 237, 237, 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: ownerTurfName,
                          decoration: InputDecoration(
                            hintText: "Turf Name",
                            fillColor: Color.fromRGBO(237, 237, 237, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 388,
                      height: 100,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(237, 237, 237, 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: ownerTurfDescription,
                          decoration: InputDecoration(
                            hintText: "Add Description",
                            fillColor: Color.fromRGBO(237, 237, 237, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          maxLines: 6,
                          minLines: 4,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Turf Images",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    SizedBox(height: 10),

                    GestureDetector(
                      onTap: () async {
                        await _pickImages();
                      },
                      child: Container(
                        width: 386,
                        height: 140,
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black45,
                            width: 1.2,
                            style: BorderStyle
                                .solid, // Use dotted_border for real dots
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap to upload turf images",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    // Show selected images
                    if (doEdit ? _fetchedImages.isNotEmpty : _images.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(doEdit ? _fetchedImages.length:_images.length, (index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 12),
                                  width: 100,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      
                                      image:doEdit ? NetworkImage("${_fetchedImages[index]}") :FileImage(
                                        File(_images[index].path),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    SizedBox(height: 130),
                    SizedBox(
                      width: 388,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (doEdit) {
                            downloadUrls = await _ownerRegisterController
                                .uploadImages(_images, email);
                            _ownerRegisterController.updateTurfData(
                              turfName: ownerTurfName.text.trim(),
                              turfDescription: ownerTurfDescription.text.trim(),
                              imageUrls: downloadUrls,
                              email_ID: email,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ownerTurfDetailScreen(
                                    email_ID: email,
                                    turfName: ownerTurfName.text.trim(), fetchedData: fetchedData, doEdit: doEdit,
                                  );
                                },
                              ),
                            );
                          } else {
                            downloadUrls = await _ownerRegisterController
                                .uploadImages(_images, email);
                                for (var i = 0; i < _fetchedImages.length; i++) {
                                  downloadUrls.add(_fetchedImages[i]);
                                }
                            _ownerRegisterController.saveTurfData(
                              turfName: ownerTurfName.text.trim(),
                              turfDescription: ownerTurfDescription.text.trim(),
                              imageUrls: downloadUrls,
                              email_ID: email,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ownerTurfDetailScreen(
                                    email_ID: email,
                                    turfName: ownerTurfName.text.trim(), fetchedData: fetchedData, doEdit: doEdit,
                                  );
                                },
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "NEXT",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
