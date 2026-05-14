// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:playz_user/Controller/user_sharedpreferences.dart';
// import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
// import 'package:playz_user/View/user_view/reusable.dart';
// import 'package:url_launcher/url_launcher.dart';

// // END: REQUIRED PLACEHOLDERS
// // ===================================================================

// // ⚠️ Replace with your valid Google Gemini API key
// const String geminiApiKey = "YOUR_GEMINI_API_KEY_HERE";
// const String geminiModel = "gemini-2.5-flash";
// String get apiUrl =>
//     "https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey";

// class ChatMessage {
//   final String role;
//   final String content;
//   final DateTime dateTime;

//   ChatMessage({
//     required this.role,
//     required this.content,
//     required this.dateTime,
//   });
// }

// // ===================================================================
// // HOSPITAL CARD WIDGET
// // ===================================================================

// class HospitalCard extends StatelessWidget {
//   final Map<String, dynamic> hospitalData;
//   final bool isDark;

//   const HospitalCard({
//     super.key,
//     required this.hospitalData,
//     required this.isDark,
//   });

//   /// Open directions in Google Maps
//   void _openDirections(double lat, double lng) async {
//     // The query 'q' specifies the destination coordinates
//     final url =
//         'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
//     final uri = Uri.parse(url);

//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       log("Could not launch $url");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Safely extract data, providing fallbacks
//     final name = hospitalData['hospital_name'] ?? 'Hospital Name Unavailable';
//     final distance = hospitalData['distance_kilometers'] ?? 'N/A';
//     final phone = hospitalData['phone_number'] ?? 'N/A';
//     final focus = hospitalData['specialization_focus'] ?? 'General Care';
//     // Use tryParse to handle cases where lat/lng might be strings or invalid
//     final lat = double.tryParse(hospitalData['latitude'].toString()) ?? 0.0;
//     final lng = double.tryParse(hospitalData['longitude'].toString()) ?? 0.0;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: isDark ? Reusable.getDarkModeBlack() : Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               name,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: isDark
//                     ? Reusable.getWhite()
//                     : Reusable.getDarkModeBlack(),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "📍 Distance: $distance",
//               style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
//             ),
//             Text(
//               "⚕️ Focus: $focus",
//               style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Call Button
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     final uri = Uri.parse('tel:$phone');
//                     if (await canLaunchUrl(uri)) {
//                       await launchUrl(uri);
//                     }
//                   },
//                   icon: const Icon(Icons.call, size: 18),
//                   label: Text('Call (${phone.split('-').last})'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Reusable.getGreen(),
//                     foregroundColor: Colors.white,
//                   ),
//                 ),

//                 // Directions Button
//                 ElevatedButton.icon(
//                   // Enable button only if valid coordinates are present
//                   onPressed: (lat != 0.0 && lng != 0.0)
//                       ? () => _openDirections(lat, lng)
//                       : null,
//                   icon: const Icon(Icons.directions, size: 18),
//                   label: const Text('Directions'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Reusable.getLightGreen(),
//                     foregroundColor: Reusable.getDarkModeBlack(),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ===================================================================
// // CHAT SCREEN WIDGET
// // ===================================================================

// class MedicalAssistantScreen extends StatefulWidget {
//   const MedicalAssistantScreen({super.key});

//   @override
//   State<MedicalAssistantScreen> createState() => _MedicalAssistantScreenState();
// }

// class _MedicalAssistantScreenState extends State<MedicalAssistantScreen> {
//   String selectedMode = "Not Selected";
//   String selectedPrompt = "";

//   void _showModeSelectionSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled:
//           true, // Allows the sheet to take full height if needed
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//       ),
//       builder: (context) {
//         // We use a StatefulBuilder to rebuild only the content of the bottom sheet
//         // when a selection is made, while still accessing the parent state.
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Container(
//               padding: const EdgeInsets.all(20.0),
//               height: 250, // Fixed height for a simple sheet
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   // Title
//                   const Text(
//                     'Select Assistant Mode',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const Divider(height: 20, thickness: 1),

//                   // Option 1: Medical Emergency
//                   _buildModeOption(
//                     setModalState,
//                     label: 'Medical Emergency',
//                     icon: Icons.local_hospital,
//                     modeValue: 'Medical Emergency',
//                     currentSelected: selectedMode,
//                   ),
//                   const SizedBox(height: 10),

//                   // Option 2: Diet
//                   _buildModeOption(
//                     setModalState,
//                     label: 'Diet Assistant',
//                     icon: Icons.restaurant,
//                     modeValue: 'Diet',
//                     currentSelected: selectedMode,
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // Helper method to build each selection option
//   Widget _buildModeOption(
//     StateSetter setModalState, {
//     required String label,
//     required IconData icon,
//     required String modeValue,
//     required String currentSelected,
//   }) {
//     final isSelected = currentSelected == modeValue;
//     return InkWell(
//       onTap: () {
//         // 3. Update the Parent State (ModeSelectionScreen)
//         setState(() {
//           selectedMode = modeValue;
//         });

//         // 4. Update the Modal State (Bottom Sheet)
//         setModalState(() {
//           // This rebuilds the sheet to show the selected indicator
//         });

//         // Close the bottom sheet after a short delay
//         Future.delayed(const Duration(milliseconds: 300), () {
//           Navigator.pop(context);
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.transparent,
//             width: 2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
//             const SizedBox(width: 15),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? Colors.blue : Colors.black87,
//               ),
//             ),
//             const Spacer(),
//             if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
//           ],
//         ),
//       ),
//     );
//   }

//   final TextEditingController _controller = TextEditingController();
//   final List<ChatMessage> _messages = [];
//   bool _sending = false;

//   // New state variables for hospital data
//   List<Map<String, dynamic>> _hospitalList = [];
//   bool _isHospitalListReady = false;

//   String _groupNameKey = "AI Assistant";

//   Future<void> _sendMessage(String userInputPrompt) async {
//     loadprompt(userInputPrompt);
//     if (userInput.trim().isEmpty || _sending) return;

//     final now = DateTime.now();

//     // Clear previous hospital list state when a new message is sent
//     setState(() {
//       _sending = true;
//       _isHospitalListReady = false; // Reset the flag
//       _hospitalList.clear(); // Clear the list
//       _messages.add(
//         ChatMessage(role: "user", content: userInput.trim(), dateTime: now),
//       );
//     });

//     final List<Map<String, String>> apiMessages = [
//       {
//         "role": "system",
//         "content":
//             "You are a helpful assistant. If the user asks for hospitals, return the JSON array exactly as requested by the user's prompt (with no markdown fences or extra text), otherwise, provide a concise text response.",
//       },
//       ..._messages.map((m) => {"role": m.role, "content": m.content}),
//     ];

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({...}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final reply =
//             (data['choices']?[0]?['message']?['content'] ?? 'No reply')
//                 .toString()
//                 .trim();

//         // --- JSON Parsing Logic ---
//         List<Map<String, dynamic>>? parsedHospitalList;
//         try {
//           final parsedList = jsonDecode(reply);

//           // Check for valid JSON array containing maps (our hospital structure)
//           if (parsedList is List &&
//               parsedList.isNotEmpty &&
//               parsedList.first is Map) {
//             // Heuristic check: See if it contains a key related to the hospital prompt
//             if (parsedList.first.containsKey('hospital_name') &&
//                 parsedList.first.containsKey('distance_kilometers')) {
//               parsedHospitalList = parsedList.cast<Map<String, dynamic>>();
//             }
//           }
//         } catch (_) {
//           // Not a parsable JSON list, ignore
//         }
//         // --- End JSON Parsing Logic ---

//         setState(() {
//           if (parsedHospitalList != null) {
//             _hospitalList = parsedHospitalList;
//             _isHospitalListReady = true;

//             // Add a simple confirmation message to the chat history
//             _messages.add(
//               ChatMessage(
//                 role: "assistant",
//                 content:
//                     "Here are the recommended hospitals based on your request:",
//                 dateTime: DateTime.now(),
//               ),
//             );
//           } else {
//             // Normal text reply
//             _isHospitalListReady = false;
//             _messages.add(
//               ChatMessage(
//                 role: "assistant",
//                 content: reply,
//                 dateTime: DateTime.now(),
//               ),
//             );
//           }
//         });
//       } else {
//         log('Response (${response.statusCode}): ${response.body}');
//         setState(() {
//           _messages.add(
//             ChatMessage(
//               role: "assistant",
//               content:
//                   'Error: Failed to connect to AI. Status ${response.statusCode}',
//               dateTime: DateTime.now(),
//             ),
//           );
//         });
//       }
//     } catch (e) {
//       log("Error: ${e}");
//       setState(() {
//         _messages.add(
//           ChatMessage(
//             role: "assistant",
//             content: 'Error: An exception occurred. Check logs.',
//             dateTime: DateTime.now(),
//           ),
//         );
//       });
//     } finally {
//       setState(() {
//         _sending = false;
//       });
//       _controller.clear();
//     }
//   }

//   void _clearChat() => setState(() {
//     _messages.clear();
//     _hospitalList.clear();
//     _isHospitalListReady = false;
//   });

//   Future<void> _loadSelectedTheme() async {
//     // Implementation relies on your actual UserSettings/ThemeSettings structure
//     // Placeholder implementation used here for compilation:
//     String? selectedTheme = await ThemeSettings(
//       theme: null,
//     ).loadSelectedTheme();
//     appSettingsNotifier.value = ThemeSettings(theme: selectedTheme);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadSelectedTheme();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showModeSelectionSheet();
//     });
//   }

//   Future<void> loadprompt(String userText) async {
//     LatLng? coOrdinates = await Appsharedpreferences().loadSelectedLatLng();
//     userInput =
//         '''Generate a JSON array of 5 hospitals due to $userText  near the coordinates "${coOrdinates?.latitude},${coOrdinates?.longitude}" that are strictly **within a 10 kilometer range**. Prioritize institutions known for high service accuracy and recent data. The required specialization for these hospitals is related to: "arm fracture". Each object in the array must strictly adhere to the following structure: {"hospital_name": "Full name of the hospital (Must be accurate)", "distance_kilometers": "estimated distance in kilometers (Must be <= 10.0 km, e.g., 5.6 km)", "phone_number": "primary contact number (Must be accurate and current, e.g.,+91-9856132564)", "location_link": "A verifiable and working Google Maps link to the hospital's location (e.g., https:maps.app.goo)", "specialization_focus": "A brief description of this hospital's relevance or department focus regarding the injury (e.g., 'Level 1 Trauma Center' or 'Orthopedic Surgery Department')"}, Ensure **absolute data accuracy and verifiability** for hospital names, phone numbers, and location links based on the provided constraints and coordinates. Return ONLY the JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences).''';
//   }

//   String userInput = "";
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeSettings>(
//       valueListenable: appSettingsNotifier,
//       builder: (context, settings, _) {
//         bool isDark = settings.theme == "Dark";
//         final double topPadding = MediaQuery.of(context).padding.top;

//         return Scaffold(
//           body: Stack(
//             children: [
//               // ✅ Green header
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: EdgeInsets.only(
//                       top: topPadding,
//                       left: 10,
//                       right: 10,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             IconButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               icon: Icon(
//                                 Icons.arrow_back_ios_new,
//                                 size: 25,
//                                 color: isDark
//                                     ? Reusable.getDarkModeBlack()
//                                     : Reusable.getWhite(),
//                               ),
//                             ),
//                             const SizedBox(width: 15),
//                             Text(
//                               _groupNameKey, // Static AI Name
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: isDark
//                                     ? Reusable.getDarkModeBlack()
//                                     : Reusable.getWhite(),
//                               ),
//                             ),
//                           ],
//                         ),
//                         // Actions like clear chat
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: _clearChat,
//                           color: isDark
//                               ? Reusable.getDarkModeBlack()
//                               : Reusable.getWhite(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // ✅ White bottom sheet for chat content area
//               Positioned(
//                 top: 110,
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? Reusable.getDarkModeBlack()
//                         : Reusable.getWhite(),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(50),
//                       topRight: Radius.circular(50),
//                     ),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color.fromRGBO(0, 0, 0, 0.25),
//                         spreadRadius: 0,
//                         blurRadius: 10,
//                         offset: Offset(0, 0),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(50),
//                       topRight: Radius.circular(50),
//                     ),
//                     // Background pattern (Kept for style continuity)
//                     child: Opacity(
//                       opacity: 0.1,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           image: DecorationImage(
//                             image: AssetImage(
//                               isDark
//                                   ? "assets/Images/dark1.png"
//                                   : "assets/Images/light1_upscaled.png",
//                             ),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Positioned elements for ListView and Input Field
//               Positioned(
//                 top: 110,
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20),

//                     // 🔹 Chat messages and Hospital List View
//                     Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(
//                           left: 20,
//                           right: 20,
//                           top: 10,
//                           bottom: 20,
//                         ),
//                         reverse: true,
//                         // If hospital list is ready, add one slot at the top (bottom of screen) for the list
//                         itemCount:
//                             _messages.length + (_isHospitalListReady ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           // --- Hospital List Display Logic (Index 0 is the bottom/latest item in reverse list) ---
//                           if (_isHospitalListReady && index == 0) {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 const SizedBox(height: 10),
//                                 ..._hospitalList.map((hospital) {
//                                   return HospitalCard(
//                                     hospitalData: hospital,
//                                     isDark: isDark,
//                                   );
//                                 }).toList(),
//                                 const SizedBox(height: 10),
//                               ],
//                             );
//                           }

//                           // --- Normal Chat Message Display Logic ---
//                           // Adjust index to account for the hospital list slot if it exists
//                           final msgIndex =
//                               _messages.length -
//                               1 -
//                               (index - (_isHospitalListReady ? 1 : 0));
//                           if (msgIndex < 0 || msgIndex >= _messages.length) {
//                             return const SizedBox.shrink(); // Safety check
//                           }

//                           final msg = _messages[msgIndex];
//                           final isUser = msg.role == "user";
//                           final String formattedTime = DateFormat(
//                             'jm',
//                           ).format(msg.dateTime);

//                           return Align(
//                             alignment: isUser
//                                 ? Alignment.centerRight
//                                 : Alignment.centerLeft,
//                             child: ConstrainedBox(
//                               constraints: BoxConstraints(
//                                 maxWidth:
//                                     MediaQuery.of(context).size.width * 0.8,
//                               ),
//                               child: Container(
//                                 margin: const EdgeInsets.symmetric(vertical: 4),
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: isUser
//                                       ? isDark
//                                             ? Reusable.getLightGreen()
//                                             : Reusable.getGreen()
//                                       : Colors.grey[300],
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: const Radius.circular(20),
//                                     topRight: const Radius.circular(20),
//                                     bottomLeft: Radius.circular(
//                                       isUser ? 20 : 0,
//                                     ),
//                                     bottomRight: Radius.circular(
//                                       isUser ? 0 : 20,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (!isUser)
//                                       const Text(
//                                         "AI Assistant",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                     const SizedBox(height: 5),
//                                     Text(
//                                       msg.content,
//                                       style: TextStyle(
//                                         color: isUser
//                                             ? isDark
//                                                   ? Reusable.getDarkModeBlack()
//                                                   : Reusable.getWhite()
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           formattedTime,
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             color: Colors.black54,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),

//                     if (_sending)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: LinearProgressIndicator(
//                           color: isDark
//                               ? Reusable.getLightGreen()
//                               : Reusable.getGreen(),
//                         ),
//                       ),

//                     // Message input field
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 15.0),
//                       child: Container(
//                         height: 60,
//                         width: MediaQuery.of(context).size.width * 0.9,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: TextField(
//                           controller: _controller,
//                           style: TextStyle(
//                             color: isDark
//                                 ? Reusable.getLightGreen()
//                                 : Reusable.getGreen(),
//                           ),
//                           cursorColor: isDark
//                               ? Reusable.getLightGreen()
//                               : Reusable.getGreen(),
//                           decoration: InputDecoration(
//                             hintText: "Ask something...",
//                             hintStyle: TextStyle(
//                               color: isDark
//                                   ? Reusable.getLightGreen()
//                                   : Reusable.getDarkGrey(),
//                             ),
//                             filled: true,
//                             fillColor: isDark
//                                 ? Reusable.getDarkModeBlack()
//                                 : Reusable.getWhite(),
//                             suffixIcon: GestureDetector(
//                               onTap: () async {
//                                 final currentLat = Appsharedpreferences().selectedLat;
//                                 final currentLng = Appsharedpreferences().selectedLng;
//                                 selectedMode == 'Medical Emergency'
//                                     ? selectedPrompt = 'Generate a JSON array of 5 hospitals near the coordinates "$currentLat,$currentLng" that are strictly **within a 10 kilometer range**. Prioritize institutions known for high service accuracy and recent data. The required specialization for these hospitals is related to: "arm fracture". Each object in the array must strictly adhere to the following structure: {"hospital_name": "Full name of the hospital (Must be accurate)", "distance_kilometers": "estimated distance in kilometers (Must be <= 10.0 km, e.g., 5.6 km)", "phone_number": "primary contact number (Must be accurate and current, e.g.,+91-9856132564)", "latitude": "The exact latitude of the hospital location (e.g., 18.450123)", "longitude": "The exact longitude of the hospital location (e.g., 73.825987)", "specialization_focus": "A brief description of this hospitals relevance or department focus regarding the injury (e.g., Level 1 Trauma Center or Orthopedic Surgery Department)"} Ensure **absolute data accuracy and verifiability** for hospital names, phone numbers, latitude, and longitude based on the provided constraints and coordinates. Return ONLY the JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences).'
//                                     : selectedPrompt = 'Generate a JSON array containing multiple diet recommendations based on the following parameters: height = <HEIGHT> cm, weight = <WEIGHT> kg, and age = <AGE> years. Each object in the array must strictly follow this structure: {"name of the food": "dish or meal name", "ingredients": "main ingredients used", "calories": "approximate calorie count in kcal", "protein": "approximate protein content in grams", "blinkit link": "a valid and clickable Blinkit URL for the main ingredient of the dish so the user can buy it directly" } Return only this JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences).';
//                                 await _sendMessage(_controller.text);
//                               },
//                               child: Icon(
//                                 Icons.send,
//                                 color: isDark
//                                     ? Reusable.getLightGreen()
//                                     : Reusable.getGreen(),
//                                 size: 30,
//                               ),
//                             ),
//                             prefixIcon: const Icon(
//                               Icons.add_circle_outline,
//                               color: Colors.grey,
//                               size: 30,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Reusable.getLightGrey(),
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: isDark
//                                     ? Reusable.getLightGreen()
//                                     : Reusable.getGreen(),
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: MediaQuery.of(context).padding.bottom > 0
//                           ? 0
//                           : 15,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

//my prompt:
//Generate a JSON array of 5 hospitals near the coordinates "18.445351,73.823234" that are strictly **within a 10 kilometer range**. Prioritize institutions known for high service accuracy and recent data.

// The required specialization for these hospitals is related to: "arm fracture".

// Each object in the array must strictly adhere to the following structure:
// {"hospital_name": "Full name of the hospital (Must be accurate)", "distance_kilometers": "estimated distance in kilometers (Must be <= 10.0 km, e.g., 5.6 km)", "phone_number": "primary contact number (Must be accurate and current, e.g.,+91-9856132564)", "latitude": "The exact latitude of the hospital location (e.g., 18.450123)", "longitude": "The exact longitude of the hospital location (e.g., 73.825987)", "specialization_focus": "A brief description of this hospital's relevance or department focus regarding the injury (e.g., 'Level 1 Trauma Center' or 'Orthopedic Surgery Department')"}

// Ensure **absolute data accuracy and verifiability** for hospital names, phone numbers, latitude, and longitude based on the provided constraints and coordinates. Return ONLY the JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences).

//use this for google maps :
/// Open directions in Google Maps
// void _openDirections() async {
//   if (_pickedLocation != null) {
//     final url =
//         "https://www.google.com/maps/dir/?api=1&destination=${_pickedLocation!.latitude},${_pickedLocation!.longitude}&travelmode=driving";
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//     }
//   }
// }

//map format
// [log] Fetched map data: [{hospital_name: Manipal Hospitals, Baner, distance_kilometers: 1.4 km, phone_number: +91-20-6833-5555, latitude: 18.559708, longitude: 73.782494, specialization_focus: Orthopaedics Department with expertise in fracture surgeries, trauma management, and minimally invasive techniques for arm fractures}, {hospital_name: Aditya Birla Memorial Hospital, distance_kilometers: 8.6 km, phone_number: +91-20-3071-7500, latitude: 18.602224, longitude: 73.776430, specialization_focus: Advanced Orthopaedic Center specializing in bone fracture management, minimally invasive and robotic-assisted trauma surgery}, {hospital_name: Sancheti Hospital, distance_kilometers: 7.1 km, phone_number: +91-20-6621-4444, latitude: 18.520430, longitude: 73.853251, specialization_focus: Dedicated Orthopaedic Trauma and Fracture Care, with specialist teams for bone and joint injury treatment}, {hospital_name: Lokmanya Hospital, Paud Road, distance_kilometers: 5.3 km, phone_number: +91-20-2543-2020, latitude: 18.505074, longitude: 73.808532, specialization_focus: Renowned for trauma and fracture treatment, offering specialized orthopedic care for arm and limb injuries}, {hospital_name: Sahyadri Hospital, Deccan Gymkhana, distance_kilometers: 6.5 km, phone_number: +91-20-6721-6500, latitude: 18.516726, longitude: 73.841990, specialization_focus: Comprehensive fracture management and orthopedic emergency services; acute bone and joint trauma expertise}]

//sample item builder:
// itemBuilder: (context, index) {
//                                       final item = chatItems[index];

//                                       // 🗓️ If it's a date header string
//                                       if (item is String) {
//                                         return Center(
//                                           child: Container(
//                                             margin: const EdgeInsets.symmetric(
//                                               vertical: 10,
//                                             ),
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 10,
//                                               vertical: 5,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey.shade300,
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                             child: Text(
//                                               item,
//                                               style: const TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       }

//                                       // 💬 Otherwise it's a chat message
//                                       final chat = item as Map<String, dynamic>;
//                                       final nameKey =
//                                           chat['name'] ?? 'Unknown Sender';
//                                       final messageKey =
//                                           chat['message'] ?? '...';
//                                       final bool isMe =
//                                           chat['email'] == currentUser;

//                                       // 🧠 Try parsing the message as a JSON array (AI-sent exercise list)
//                                       List<dynamic>? exerciseList;
//                                       try {
//                                         final parsed = jsonDecode(messageKey);
//                                         if (parsed is List &&
//                                             parsed.isNotEmpty &&
//                                             parsed.first is Map) {
//                                           exerciseList = parsed;
//                                         }
//                                       } catch (_) {
//                                         exerciseList = null;
//                                       }

//                                       return Align(
//                                         alignment: isMe
//                                             ? Alignment.centerRight
//                                             : Alignment.centerLeft,
//                                         child: ConstrainedBox(
//                                           constraints: BoxConstraints(
//                                             maxWidth:
//                                                 MediaQuery.of(
//                                                   context,
//                                                 ).size.width *
//                                                 0.8,
//                                           ),
//                                           child: Container(
//                                             margin: const EdgeInsets.symmetric(
//                                               vertical: 4,
//                                             ),
//                                             padding: const EdgeInsets.all(10),
//                                             decoration: BoxDecoration(
//                                               color: isMe
//                                                   ? isDark
//                                                         ? Reusable.getLightGreen()
//                                                         : Reusable.getGreen()
//                                                   : Colors.grey[300],
//                                               borderRadius: BorderRadius.only(
//                                                 topLeft: Radius.circular(
//                                                   Reusable.getDeviceWidth(
//                                                     context,
//                                                     W: 20,
//                                                   ),
//                                                 ),
//                                                 topRight: Radius.circular(
//                                                   Reusable.getDeviceWidth(
//                                                     context,
//                                                     W: 20,
//                                                   ),
//                                                 ),
//                                                 bottomLeft: Radius.circular(
//                                                   Reusable.getDeviceWidth(
//                                                     context,
//                                                     W: isMe ? 20 : 0,
//                                                   ),
//                                                 ),
//                                                 bottomRight: Radius.circular(
//                                                   Reusable.getDeviceWidth(
//                                                     context,
//                                                     W: isMe ? 0 : 20,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 if (!isMe)
//                                                   Text(
//                                                     _getTranslation(nameKey),
//                                                     style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.black87,
//                                                     ),
//                                                   ),
//                                                 // const SizedBox(height: 500),

//                                                 // 🧩 CASE 1: If message is an exercise list (decoded JSON array)
//                                                 if (exerciseList != null)
//                                                   Column(
//                                                     children: exerciseList.map((
//                                                       exercise,
//                                                     ) {
//                                                       return Card(
//                                                         margin:
//                                                             const EdgeInsets.symmetric(
//                                                               vertical: 5,
//                                                             ),
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.circular(
//                                                                 12,
//                                                               ),
//                                                         ),
//                                                         color: isDark
//                                                             ? Colors.grey[850]
//                                                             : Colors
//                                                                   .grey
//                                                                   .shade200
//                                                                   .withOpacity(
//                                                                     0.9,
//                                                                   ),
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets.all(
//                                                                 12,
//                                                               ),
//                                                           child: Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 exercise['exercise'] ??
//                                                                     'N/A',
//                                                                 style: TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontSize: 16,
//                                                                   color: isDark
//                                                                       ? Colors
//                                                                             .white
//                                                                       : Colors
//                                                                             .black,
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                 height: 4,
//                                                               ),
//                                                               Text(
//                                                                 "Reps: ${exercise['no of repetetions'] ?? 'N/A'}",
//                                                                 style: TextStyle(
//                                                                   color: isDark
//                                                                       ? Colors
//                                                                             .white70
//                                                                       : Colors
//                                                                             .grey
//                                                                             .shade800,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 "How to: ${exercise['how to do it'] ?? 'N/A'}",
//                                                                 style: TextStyle(
//                                                                   color: isDark
//                                                                       ? Colors
//                                                                             .white70
//                                                                       : Colors
//                                                                             .grey
//                                                                             .shade800,
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                 height: 6,
//                                                               ),
//                                                               if (exercise['youtube link'] !=
//                                                                       null &&
//                                                                   (exercise['youtube link']
//                                                                           as String)
//                                                                       .isNotEmpty)
//                                                                 ElevatedButton.icon(
//                                                                   style: ElevatedButton.styleFrom(
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .red,
//                                                                     shape: RoundedRectangleBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                             8,
//                                                                           ),
//                                                                     ),
//                                                                     padding: const EdgeInsets.symmetric(
//                                                                       horizontal:
//                                                                           12,
//                                                                       vertical:
//                                                                           8,
//                                                                     ),
//                                                                   ),
//                                                                   icon: const Icon(
//                                                                     Icons
//                                                                         .play_circle_fill,
//                                                                     color: Colors
//                                                                         .white,
//                                                                   ),
//                                                                   label: const Text(
//                                                                     "Watch on YouTube",
//                                                                     style: TextStyle(
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                   ),
//                                                                   onPressed: () async {
//                                                                     final url =
//                                                                         Uri.parse(
//                                                                           exercise['youtube link'],
//                                                                         );
//                                                                     if (await canLaunchUrl(
//                                                                       url,
//                                                                     )) {
//                                                                       await launchUrl(
//                                                                         url,
//                                                                         mode: LaunchMode
//                                                                             .inAppWebView,
//                                                                       );
//                                                                     } else {
//                                                                       ScaffoldMessenger.of(
//                                                                         context,
//                                                                       ).showSnackBar(
//                                                                         const SnackBar(
//                                                                           content: Text(
//                                                                             "Could not open YouTube link",
//                                                                           ),
//                                                                         ),
//                                                                       );
//                                                                     }
//                                                                   },
//                                                                 ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }).toList(),
//                                                   )
//                                                 // 💬 CASE 2: Normal text message
//                                                 else
//                                                   Text(
//                                                     _getTranslation(messageKey),
//                                                     style: TextStyle(
//                                                       color: isMe
//                                                           ? isDark
//                                                                 ? Reusable.getDarkModeBlack()
//                                                                 : Reusable.getWhite()
//                                                           : Colors.black87,
//                                                     ),
//                                                   ),

//                                                 const SizedBox(height: 5),
//                                                 Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Text(
//                                                       chat['time']!,
//                                                       style: const TextStyle(
//                                                         fontSize: 10,
//                                                         color: Colors.black54,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:url_launcher/url_launcher.dart';

// END: REQUIRED PLACEHOLDERS
// ===================================================================

// ⚠️ Replace with your valid Google Gemini API key
const String geminiApiKey = "AIzaSyAIqRzXGO72L94qsjQGKbkbW6163ujXITM";
const String geminiModel = "gemini-2.5-flash";
String get apiUrl =>
    "https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey";

class ChatMessage {
  final String role;
  final String content;
  final DateTime dateTime;

  ChatMessage({
    required this.role,
    required this.content,
    required this.dateTime,
  });
}

// ===================================================================
// HOSPITAL CARD WIDGET
// ===================================================================

class HospitalCard extends StatelessWidget {
  final Map<String, dynamic> hospitalData;
  final bool isDark;

  const HospitalCard({
    super.key,
    required this.hospitalData,
    required this.isDark,
  });

  /// Open directions in Google Maps
  void _openDirections(double lat, double lng) async {
    // The query 'q' specifies the destination coordinates
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract data, providing fallbacks
    final name = hospitalData['hospital_name'] ?? 'Hospital Name Unavailable';
    final distance = hospitalData['distance_kilometers'] ?? 'N/A';
    final phone = hospitalData['phone_number'] ?? 'N/A';
    final focus = hospitalData['specialization_focus'] ?? 'General Care';
    // Use tryParse to handle cases where lat/lng might be strings or invalid
    final lat = double.tryParse(hospitalData['latitude'].toString()) ?? 0.0;
    final lng = double.tryParse(hospitalData['longitude'].toString()) ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Reusable.getDarkModeBlack() : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark
                    ? Reusable.getWhite()
                    : Reusable.getDarkModeBlack(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "📍 Distance: $distance",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            Text(
              "⚕️ Focus: $focus",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Call Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 18),
                  label: Text('Call (${phone.split('-').last})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Reusable.getGreen(),
                    foregroundColor: Colors.white,
                  ),
                ),

                // Directions Button
                ElevatedButton.icon(
                  // Enable button only if valid coordinates are present
                  onPressed: (lat != 0.0 && lng != 0.0)
                      ? () => _openDirections(lat, lng)
                      : null,
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Reusable.getLightGreen(),
                    foregroundColor: Reusable.getDarkModeBlack(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// FOOD CARD WIDGET (NEW)
// ===================================================================

class FoodCard extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final bool isDark;

  const FoodCard({super.key, required this.foodData, required this.isDark});

  /// Build a Blinkit search query (URL-encoded) from raw input or existing link.
  String _buildBlinkitQuery(String raw) {
    if (raw.trim().isEmpty) return '';
    final input = raw.trim();

    // Try to parse as URI and extract 'q' query parameter if present
    Uri? uri = Uri.tryParse(input);
    String q = '';
    if (uri != null) {
      q = uri.queryParameters['q'] ?? '';
    }

    // If no q param, use the path or raw text as fallback
    if (q.isEmpty) {
      q = input;
    }

    // Decode and extract simple tokens (words/numbers). Keep multi-word ingredients by joining tokens.
    try {
      q = Uri.decodeComponent(q);
    } catch (_) {}

    // Extract words (allow hyphenated and plus) and keep them
    final tokens = RegExp(
      r"[A-Za-z0-9]+(?:[-'][A-Za-z0-9]+)?",
    ).allMatches(q).map((m) => m.group(0)!).toList();

    if (tokens.isEmpty) return '';

    final selected = tokens.take(4).toList();
    final encoded = selected.map((s) => Uri.encodeComponent(s)).join('%20');
    return encoded;
  }

  /// Try multiple Blinkit link formats to ensure the app opens with a prefilled search.
  /// Attempts in order: blinkit scheme variants, Android intent:// variants with common package names, then web fallback.
  void _openBlinkitLink(String urlString) async {
    final query = _buildBlinkitQuery(urlString);
    final List<String> candidates = [];

    if (query.isNotEmpty) {
      candidates.add('blinkit://search?q=$query');
      candidates.add('blinkit://search/?q=$query');
      candidates.add('https://blinkit.com/s/?q=$query');
      candidates.add('https://www.blinkit.com/s/?q=$query');
    }

    // Android intent fallbacks - try a few package names commonly used for Blinkit/Grofers
    final packages = [
      'in.blinkit.app',
      'com.blinkit.android',
      'com.grofers.android',
    ];
    for (final pkg in packages) {
      if (query.isNotEmpty) {
        candidates.add(
          'intent://search?q=$query#Intent;scheme=blinkit;package=$pkg;end',
        );
        candidates.add(
          'intent://search/?q=$query#Intent;scheme=blinkit;package=$pkg;end',
        );
      }
    }

    // Also try the original urlString as a last web fallback
    candidates.add(urlString);

    for (final candidate in candidates) {
      try {
        final uri = Uri.tryParse(candidate);
        if (uri == null) continue;

        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return;
        }
      } catch (e) {
        log('Blinkit launch attempt failed for $candidate: $e');
      }
    }

    log("Could not launch Blinkit with any candidate for input: $urlString");
  }

  @override
  Widget build(BuildContext context) {
    final name =
        foodData['name'] ??
        foodData['name of the food'] ??
        'Food Name Unavailable';
    final ingredients =
        foodData['ingredients'] ?? foodData['ingredient'] ?? 'N/A';
    final calories = foodData['calories'] ?? foodData['calorie'] ?? 'N/A';
    final protein = foodData['protein'] ?? foodData['protein_content'] ?? 'N/A';
    final blinkitLink =
        (foodData['blinkit_link'] ??
                foodData['blinkit_app_link'] ??
                foodData['blinkit link'] ??
                foodData['blinkit'] ??
                '')
            .toString()
            .trim();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Reusable.getDarkModeBlack() : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark
                    ? Reusable.getWhite()
                    : Reusable.getDarkModeBlack(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "🍽️ Ingredients: $ingredients",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            Text(
              "🔥 Calories: $calories",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            Text(
              "💪 Protein: $protein",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            // Blinkit Button
            ElevatedButton.icon(
              onPressed: blinkitLink.isNotEmpty
                  ? () => _openBlinkitLink(blinkitLink)
                  : null,
              icon: const Icon(Icons.shopping_bag, size: 18),
              label: const Text('Buy Main Ingredient (Blinkit)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Reusable.getGreen(), // Use a distinct color
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// DIET INPUT SHEET WIDGET (NEW)
// ===================================================================

class DietInputSheet extends StatefulWidget {
  final Function(String height, String weight, String age) onDataSubmitted;

  const DietInputSheet({super.key, required this.onDataSubmitted});

  @override
  State<DietInputSheet> createState() => _DietInputSheetState();
}

class _DietInputSheetState extends State<DietInputSheet> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  void _submitData() {
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final age = _ageController.text.trim();

    if (height.isNotEmpty && weight.isNotEmpty && age.isNotEmpty) {
      Navigator.pop(context); // Close the sheet
      widget.onDataSubmitted(height, weight, age);
    } else {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all values.')));
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter Diet Parameters',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20, thickness: 1),
          _buildTextField(_heightController, 'Height', 'cm'),
          _buildTextField(_weightController, 'Weight', 'kg'),
          _buildTextField(_ageController, 'Age', 'years'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Reusable.getGreen(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Get Diet Recommendations'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// CHAT SCREEN WIDGET
// ===================================================================

class MedicalAssistantScreen extends StatefulWidget {
  const MedicalAssistantScreen({super.key});

  @override
  State<MedicalAssistantScreen> createState() => _MedicalAssistantScreenState();
}

class _MedicalAssistantScreenState extends State<MedicalAssistantScreen> {
  String selectedMode = "Not Selected";
  String selectedPrompt = "";

  // New state for diet inputs
  String _userHeight = '';
  String _userWeight = '';
  String _userAge = '';

  void _showModeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Prevents external tap/swipe dismissal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (sheetContext) {
        // Renamed context to sheetContext for clarity
        // 1. Wrap the sheet content with WillPopScope to intercept the hardware back button
        return WillPopScope(
          onWillPop: () async {
            // 2. Pop the bottom sheet first (using the sheet's context)
            Navigator.of(sheetContext).pop();

            // 3. Pop the entire page below the sheet (using the widget's context)
            // Since you are in a State method, 'context' refers to the page context.
            Navigator.of(context).pop();

            // 4. Return false to indicate that we handled the pop event
            return false;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: const EdgeInsets.all(20.0),
                height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Select Assistant Mode',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20, thickness: 1),

                    // Option 1: Medical Emergency
                    _buildModeOption(
                      setModalState,
                      label: 'Medical Emergency',
                      icon: Icons.local_hospital,
                      modeValue: 'Medical Emergency',
                      currentSelected: selectedMode,
                    ),
                    const SizedBox(height: 10),

                    // Option 2: Diet
                    _buildModeOption(
                      setModalState,
                      label: 'Diet Assistant',
                      icon: Icons.restaurant,
                      modeValue: 'Diet',
                      currentSelected: selectedMode,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModeOption(
    StateSetter setModalState, {
    required String label,
    required IconData icon,
    required String modeValue,
    required String currentSelected,
  }) {
    final isSelected = currentSelected == modeValue;
    return InkWell(
      onTap: () {
        // 1. Update the Parent State (ModeSelectionScreen)
        setState(() {
          selectedMode = modeValue;
        });

        // 2. Update the Modal State (Bottom Sheet)
        setModalState(() {
          // This rebuilds the sheet to show the selected indicator
        });

        // 3. Close the bottom sheet and potentially open diet input
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pop(context);
          if (modeValue == 'Diet') {
            _showDietInputSheet();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _showDietInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DietInputSheet(
          onDataSubmitted: (height, weight, age) {
            setState(() {
              _userHeight = height;
              _userWeight = weight;
              _userAge = age;
            });
            // Automatically prompt the user to ask for diet
            _controller.text = "Give me diet recommendations";
            // The next _sendMessage call will use the stored data
          },
        );
      },
    );
  }

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  // Helper: extract the first JSON array from a possibly-fenced/annotated reply.
  // Returns the substring starting with '[' and ending with the matching ']',
  // or the original text if no balanced array is found.
  String _extractFirstJsonArray(String text) {
    if (text.isEmpty) return text;

    // Remove common markdown fences and language tags
    text = text.replaceAll(RegExp(r'```(?:\w+)?\n?'), '\n');
    // Remove any remaining backticks
    text = text.replaceAll('`', '');

    final int start = text.indexOf('[');
    if (start == -1) return text;

    int depth = 0;
    for (int i = start; i < text.length; i++) {
      final ch = text[i];
      if (ch == '[') {
        depth++;
      } else if (ch == ']') {
        depth--;
        if (depth == 0) {
          return text.substring(start, i + 1).trim();
        }
      }
    }

    // No balanced array found, return original text
    return text;
  }

  // State variables for hospital data
  List<Map<String, dynamic>> _hospitalList = [];
  bool _isHospitalListReady = false;

  // New state variables for food data
  List<Map<String, dynamic>> _foodList = [];
  bool _isFoodListReady = false;

  String _groupNameKey = "AI Assistant";

  Future<void> _sendMessage(String userInputPrompt) async {
    await loadprompt(userInputPrompt); // Await here to ensure userInput is set
    if (userInput.trim().isEmpty || _sending) return;

    final now = DateTime.now();

    // Clear previous list state when a new message is sent
    setState(() {
      _sending = true;
      _isHospitalListReady = false; // Reset hospital flag
      _hospitalList.clear(); // Clear hospital list
      _isFoodListReady = false; // Reset food flag
      _foodList.clear(); // Clear food list
      _messages.add(
        ChatMessage(
          role: "user",
          content: userInputPrompt.trim(),
          dateTime: now,
        ), // Use the original user input for display
      );
    });

    // Build Gemini request body
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": userInput},
          ],
        },
      ],
      "systemInstruction": {
        "parts": [
          {
            "text":
                "You are a helpful assistant. Only return the JSON array as requested by the user's prompt (with no markdown fences or extra text). Do not add any extra text outside the JSON structure. most important note never include ''' json ''' in your result just give json array",
          },
        ],
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
                    'No reply')
                .toString()
                .trim();

        // Sanitize reply: extract the first JSON array substring if present
        final sanitizedReply = _extractFirstJsonArray(reply);

        // --- JSON Parsing Logic ---
        List<Map<String, dynamic>>? parsedList;
        try {
          // Attempt to parse the sanitized reply as a JSON array
          final decodedReply = jsonDecode(sanitizedReply);
          if (decodedReply is List && decodedReply.isNotEmpty) {
            parsedList = decodedReply.cast<Map<String, dynamic>>();
          }
        } catch (_) {
          // Not a parsable JSON list
        }

        // --- Determine the type of list (Hospital or Food) ---
        bool isHospital = false;
        bool isFood = false;

        if (parsedList != null && parsedList.isNotEmpty) {
          final firstItem = parsedList.first;
          if (firstItem.containsKey('hospital_name') &&
              firstItem.containsKey('distance_kilometers')) {
            isHospital = true;
          } else if ((firstItem.containsKey('name') ||
                  firstItem.containsKey('name of the food') ||
                  firstItem.containsKey('dish')) &&
              (firstItem.containsKey('blinkit_link') ||
                  firstItem.containsKey('blinkit_app_link') ||
                  firstItem.containsKey('blinkit link') ||
                  firstItem.containsKey('blinkit'))) {
            // It's a food list. Normalize keys so UI code can rely on a consistent schema.
            isFood = true;

            parsedList = parsedList.map((m) {
              final name =
                  m['name'] ?? m['name of the food'] ?? m['dish'] ?? '';
              final ingredients = m['ingredients'] ?? m['ingredient'] ?? '';
              final calories = m['calories'] ?? m['calorie'] ?? '';
              final protein = m['protein'] ?? m['protein_content'] ?? '';
              // Accept app-specific key 'blinkit_app_link' as well and normalize to 'blinkit_link'
              final blinkit =
                  m['blinkit_link'] ??
                  m['blinkit_app_link'] ??
                  m['blinkit link'] ??
                  m['blinkit'] ??
                  '';

              return {
                'name': name,
                'ingredients': ingredients,
                'calories': calories,
                'protein': protein,
                'blinkit_link': blinkit,
              };
            }).toList();
          }
        }
        // --- End List Type Determination ---

        setState(() {
          if (isHospital) {
            _hospitalList = parsedList!;
            _isHospitalListReady = true;

            // Add a confirmation message to the chat history
            _messages.add(
              ChatMessage(
                role: "assistant",
                content:
                    "Here are the recommended hospitals based on your request:",
                dateTime: DateTime.now(),
              ),
            );
          } else if (isFood) {
            _foodList = parsedList!;
            _isFoodListReady = true;

            // Add a confirmation message to the chat history
            _messages.add(
              ChatMessage(
                role: "assistant",
                content:
                    "Here are the diet recommendations based on your parameters:",
                dateTime: DateTime.now(),
              ),
            );
          } else {
            // Normal text reply if no matching JSON was found
            _isHospitalListReady = false;
            _isFoodListReady = false;
            _messages.add(
              ChatMessage(
                role: "assistant",
                content: reply,
                dateTime: DateTime.now(),
              ),
            );
          }
        });
      } else {
        log('Response (${response.statusCode}): ${response.body}');
        String errorContent;
        switch (response.statusCode) {
          case 400:
            errorContent =
                'Error: Bad request. The input may be too long or invalid.';
            break;
          case 401:
            errorContent =
                'Error: Invalid API key. Please check your Gemini API key.';
            break;
          case 429:
            errorContent =
                'Error: Rate limit exceeded. Please try again later.';
            break;
          case 500:
            errorContent =
                'Error: Gemini server error. Please try again later.';
            break;
          default:
            errorContent =
                'Error: Failed to connect to AI. Status ${response.statusCode}';
        }
        setState(() {
          _messages.add(
            ChatMessage(
              role: "assistant",
              content: errorContent,
              dateTime: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      log("Error: $e");
      setState(() {
        _messages.add(
          ChatMessage(
            role: "assistant",
            content: 'Error: An exception occurred. Check logs.',
            dateTime: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() {
        _sending = false;
      });
      _controller.clear();
    }
  }

  void _clearChat() => setState(() {
    _messages.clear();
    _hospitalList.clear();
    _isHospitalListReady = false;
    _foodList.clear();
    _isFoodListReady = false;
  });

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await ThemeSettings(
      theme: null,
    ).loadSelectedTheme();
    appSettingsNotifier.value = ThemeSettings(theme: selectedTheme);
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModeSelectionSheet();
    });
  }

  Future<void> loadprompt(String userText) async {
    if (selectedMode == 'Medical Emergency') {
      LatLng? coOrdinates = await Appsharedpreferences().loadSelectedLatLng();
      userInput =
          '''Generate a JSON array of exactly 5 hospital objects for the request: $userText near the coordinates "${coOrdinates?.latitude},${coOrdinates?.longitude}". Each object must strictly follow this structure: {"hospital_name":"<full name>","address":"<full street address, city, postal code>","distance_kilometers":"<e.g. 5.6 km>","phone_number":"<E.164 format, e.g. +91-9999999999>","location_link":"<verifiable Google Maps URL, e.g. https://www.google.com/maps/place/... or https://maps.app.goo.gl/...>","latitude":"<decimal latitude>","longitude":"<decimal longitude>","specialization_focus":"<short description>"}

Requirements:
- Provide exactly 5 hospitals within 10.0 km of the coordinates provided.
- Ensure fields are accurate, verifiable and up-to-date. Phone numbers must include country code and be callable.
- `address` must be a full street address (street, locality, city, postal code when available).
- `location_link` must be a working Google Maps URL pointing to the hospital (no generic search pages). Prefer `https://www.google.com/maps/place/...` or `https://maps.app.goo.gl/...`.

Output rules (must be followed exactly):
1) Return only a single raw JSON array and nothing else.
2) Do NOT include any explanation, commentary, labels, backticks, or Markdown/code fences (do NOT output ```json or ```).
3) The response must begin with '[' and end with ']'.
4) All fields must be accurate and verifiable; omit any hospital you cannot verify precisely.
''';
    } else if (selectedMode == 'Diet') {
      // Use the stored height, weight, and age
      userInput =
          '''Generate a JSON array of 5 diet recommendation objects for the user's parameters: {height = ${_userHeight} cm, weight = ${_userWeight} kg, age = ${_userAge} years} and request: "${userText}". Each object must strictly follow this structure: {"name":"<dish name>","ingredients":"<main ingredients>","calories":"<kcal>","protein":"<grams>","blinkit_app_link":"<Blinkit app deep link like https://blinkit.com/s/?q=oats%20banana%20peanut%20butter%20milk>"}.

Rules for the `blinkit_app_link` field (must be followed):
- Prefer an app deep link of the exact form `blinkit://search?q=ING1%20ING2%20ING3` that pre-fills 2 to 4 main ingredients. Example: `https://blinkit.com/s/?q=oats%20banana%20peanut%20butter%20milk`.

Output rules (must be followed exactly):
- Return only a single raw JSON array and nothing else.
- Do NOT include any explanation, commentary, labels, backticks, or Markdown/code fences.
- The response must begin with '[' and end with ']'.
''';
    } else {
      userInput = userText; // Fallback for other modes
    }
  }

  String userInput = "";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        final double topPadding = MediaQuery.of(context).padding.top;

        return Scaffold(
          body: Stack(
            children: [
              // ✅ Green header
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: topPadding,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: 25,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              _groupNameKey, // Static AI Name
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                          ],
                        ),
                        // Actions like clear chat
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _clearChat,
                          color: isDark
                              ? Reusable.getDarkModeBlack()
                              : Reusable.getWhite(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ White bottom sheet for chat content area
              Positioned(
                top: 110,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    // Background pattern (Kept for style continuity)
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage(
                              isDark
                                  ? "assets/Images/dark1.png"
                                  : "assets/Images/light1_upscaled.png",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned elements for ListView and Input Field
              Positioned(
                top: 110,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 🔹 Chat messages and List View
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 20,
                        ),
                        reverse: true,
                        // Item count logic: messages + (1 if hospital list is ready) + (1 if food list is ready)
                        itemCount:
                            _messages.length +
                            (_isHospitalListReady ? 1 : 0) +
                            (_isFoodListReady ? 1 : 0),
                        itemBuilder: (context, index) {
                          // --- List Display Logic (Index 0 is the bottom/latest item in reverse list) ---
                          if (index == 0) {
                            if (_isHospitalListReady) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),
                                  ..._hospitalList.map((hospital) {
                                    return HospitalCard(
                                      hospitalData: hospital,
                                      isDark: isDark,
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10),
                                ],
                              );
                            } else if (_isFoodListReady) {
                              // NEW: Food List Display
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),
                                  ..._foodList.map((food) {
                                    return FoodCard(
                                      foodData: food,
                                      isDark: isDark,
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }
                          }

                          // --- Normal Chat Message Display Logic ---
                          // Calculate the offset for the messages list
                          int listOffset = 0;
                          if (_isHospitalListReady) listOffset++;
                          if (_isFoodListReady) listOffset++;

                          final msgIndex =
                              _messages.length - 1 - (index - listOffset);
                          if (msgIndex < 0 || msgIndex >= _messages.length) {
                            return const SizedBox.shrink(); // Safety check
                          }

                          final msg = _messages[msgIndex];
                          final isUser = msg.role == "user";
                          final String formattedTime = DateFormat(
                            'jm',
                          ).format(msg.dateTime);

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen()
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(
                                      isUser ? 20 : 0,
                                    ),
                                    bottomRight: Radius.circular(
                                      isUser ? 0 : 20,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser)
                                      const Text(
                                        "AI Assistant",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        color: isUser
                                            ? isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite()
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (_sending)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                        ),
                      ),

                    // Message input field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                          ),
                          cursorColor: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                          decoration: InputDecoration(
                            hintText: "Ask something...",
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                await _sendMessage(_controller.text);
                              },
                              child: Icon(
                                Icons.send,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                size: 30,
                              ),
                            ),
                            prefixIcon: GestureDetector(
                              onTap: _showModeSelectionSheet,
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Reusable.getLightGrey(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom > 0
                          ? 0
                          : 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
