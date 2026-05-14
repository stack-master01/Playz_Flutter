import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/Trainer_Controller/Trainer_Profile_Controller.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/sessions_screen.dart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';
import 'package:playz_user/View/trainer_view/screen/screens/screens/Trainer_Map_Picker.dart';

class DetailsAndSkillsScreen extends StatefulWidget {
  const DetailsAndSkillsScreen({super.key});

  @override
  State<DetailsAndSkillsScreen> createState() => _DetailsAndSkillsScreenState();
}

class _DetailsAndSkillsScreenState extends State<DetailsAndSkillsScreen> {
  final TextEditingController sportController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> selectedSports = ['Cricket', 'Football'];
  Map<String, bool> trainingFor = {
    "Kids": true,
    "Adults": true,
    "Women_only": true,
  };

  LatLng? selectedLatLng;
  String? selectedAddress;

  void addSport(String sport) {
    if (sport.isNotEmpty && !selectedSports.contains(sport)) {
      setState(() {
        selectedSports.add(sport);
      });
      sportController.clear();
    }
  }

  void removeSport(String sport) {
    setState(() {
      selectedSports.remove(sport);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  "Details and Skills",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Step Indicator
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
                        child: Divider(color: Colors.grey, thickness: 2)),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey,
                      child: Text("3", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Select Sport
                const Text(
                  "Select Sport",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: sportController,
                  decoration: InputDecoration(
                    hintText: "Search a Sport",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: addSport,
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: selectedSports
                      .map(
                        (sport) => Chip(
                          backgroundColor: Colors.grey.shade100,
                          label: Text(sport),
                          deleteIcon:
                              const Icon(Icons.close, color: Colors.deepOrange),
                          onDeleted: () => removeSport(sport),
                          labelStyle: const TextStyle(color: Colors.black),
                          side: const BorderSide(color: Colors.deepOrange),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 20),

                // Trainer Location
                const Text(
                  "Trainer Location",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainerMapPickerPage(
                          onLocationPicked: (LatLng pos, String address) async {
                            setState(() {
                              selectedLatLng = pos;
                              selectedAddress = address;
                            });
                            log("Trainer Location Address: $address");
                            log("Trainer Location LatLng: $pos");
                          },
                        ),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: selectedAddress ?? "Select location",
                        suffixIcon: const Icon(Icons.location_on_outlined,
                            color: Colors.deepOrange),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Training Sessions For
                const Text(
                  "Training Sessions For",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: trainingFor.keys.map((key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: trainingFor[key],
                        onChanged: (val) {
                          setState(() {
                            trainingFor[key] = val!;
                          });
                        },
                        activeColor: Colors.deepOrange,
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // About you
                const Text(
                  "About you",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: aboutController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter about you",
                    filled: true,
                    fillColor: Colors.grey.shade100,
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
                      "about":aboutController.text.trim(),
                      "location":{
                        "address": selectedAddress ?? "",
                        "latitude": selectedLatLng?.latitude ?? 0,
                        "longitude": selectedLatLng?.longitude ?? 0
                      },
                      "session_types":trainingFor,
                      "sports": selectedSports,


                    });
                      Navigator.pop(context);
                      Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SessionsScreen()),
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
      ),
    );
  }
}

class DetailsAndSkillsScreen2 {
  const DetailsAndSkillsScreen2();
}
