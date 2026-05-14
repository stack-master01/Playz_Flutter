import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_TurfRegistered_Successful.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/RegisterTurf_Screen.dart';
// Assuming these imports point to valid classes



// End of placeholder classes


class ownerTurfRegisteredSuccessfulScreen extends StatefulWidget {
  const ownerTurfRegisteredSuccessfulScreen({super.key});

  @override
  State<ownerTurfRegisteredSuccessfulScreen> createState() =>
      _ownerTurfRegisteredSuccessfulScreenState();
}

class _ownerTurfRegisteredSuccessfulScreenState
    extends State<ownerTurfRegisteredSuccessfulScreen> {
  // Define a consistent primary color
  final Color primaryColor = const Color.fromRGBO(13, 71, 161, 1);
  final String networkImageUrl =
      'https://images.unsplash.com/photo-1543329241-d50d603a111a?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'; // A generic turf/sports image

  List<String> registeredTurf = [];
  @override
  void initState(){
    super.initState();
    registeredTurf.clear();
    getTurfNameData();
  }
  void getTurfNameData()async{
    OwnerSettings _ownerSetting = await OwnerSettings().loadSettings();
    OwnerTurfregisteredSuccessful _getFirebaseData = OwnerTurfregisteredSuccessful();
    QuerySnapshot firebaseTurfData = await _getFirebaseData.getTurfData(_ownerSetting.ownerEmail);
    for(int i = 0 ; i < firebaseTurfData.docs.length ; i++){
      registeredTurf.add(firebaseTurfData.docs[i]['turfName']);
    }
    setState(() {
      
    });
    final data = firebaseTurfData.docs;
    
    log("List:${registeredTurf}");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Screen Background Image with Opacity
          Opacity(
            opacity: 0.5,
            child: Image.network(
              networkImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.blueGrey), // Fallback color
            ),
          ),

          // 2. Overlay Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              // Ensures the content is scrollable if it exceeds screen height
              padding: const EdgeInsets.only(top: 60.0, bottom: 40.0),
              children: [
                // Success Icon
                Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Turf Registered",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    shadows: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(1, 1))
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Subtitle
                Text(
                  "Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    shadows: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(1, 1))
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // List of Registered Turfs (Wrapped for visibility against background)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85), // Semi-transparent white background
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registered Turfs:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const Divider(height: 15, thickness: 1),
                      // Using ListView.builder inside a Column needs ShrinkWrap
                      ListView.builder(
                        shrinkWrap: true, // Crucial when nesting ListView in ListView/Column
                        physics: const NeverScrollableScrollPhysics(), // Disables nested scrolling
                        itemCount: registeredTurf.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: Icon(Icons.sports_soccer_rounded,
                                  color: primaryColor),
                              title: Text(
                                registeredTurf[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Spacer to push buttons to the bottom-ish area
                const SizedBox(height: 80),
                
                // // Primary Action Button (Add Another Turf)
                // SizedBox(
                //   height: 56,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.of(context).pushReplacement(
                //         MaterialPageRoute(
                //           builder: (context) =>  ownerRegisterTurfScreen(),
                //         ),
                //       );
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: primaryColor, // Use primary color for main action
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12), // Slightly less rounded
                //       ),
                //       elevation: 5, // Add a bit of shadow
                //     ),
                //     child: const Text(
                //       "Add Another Turf",
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 15),
                
                // Secondary Action Button (Go To Dashboard)
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const OwnerDashBoardScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor, // Text color
                      side: BorderSide(
                          color: primaryColor,
                          width: 2), // Outline border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.9), // Slightly opaque white background for contrast
                    ),
                    child: Text(
                      "Go To Dashboard",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}