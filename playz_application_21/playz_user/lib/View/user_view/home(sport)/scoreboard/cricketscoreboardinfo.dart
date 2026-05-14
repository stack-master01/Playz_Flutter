// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:playz_user/View/home(sport)/scoreboard/cricketscoreboard.dart';
// import 'package:playz_user/View/menu(sport)/appsharedpreferences.dart';
// import 'package:playz_user/View/menu(sport)/menu(sport).dart';
// import 'package:playz_user/View/reusable.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CricketScoreboardInfo extends StatefulWidget {
//   const CricketScoreboardInfo({super.key});

//   @override
//   State<CricketScoreboardInfo> createState() => _CricketScoreboardInfoState();
// }

// class _CricketScoreboardInfoState extends State<CricketScoreboardInfo> {
//   List<TextEditingController?> teamAPlayers = List.generate(
//     11,
//     (_) => TextEditingController(),
//   );

//   List<TextEditingController?> teamBPlayers = List.generate(
//     11,
//     (_) => TextEditingController(),
//   );

//   int totalPlayers = 4;
//   int totalOvers = 10;
//   List<List<String>> pageItems = [
//     ["Item 1", "Item 2", "Item 3"],
//     ["Item A", "Item B"],
//     ["One", "Two"],
//   ];
//   String? selectedOver;
//   int? selectedOverNo;
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeSettings>(
//       valueListenable: appSettingsNotifier, // listen for changes
//       builder: (context, settings, _) {
//         bool isDark = settings.theme == "Dark";

//         return Scaffold(
//           body: Stack(
//             // Stack is used to overlap top header and white sheet
//             children: [
//               // 🔹 Green header background
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),

//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       top: 40,
//                       left: 10,
//                       right: 10,
//                     ),
//                     child: Row(
//                       children: [
//                         // 🔙 Back button
//                         IconButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           icon: Icon(
//                             Icons.arrow_back_ios_new,
//                             size: Reusable.getDeviceWidth(context, W: 25),
//                             color: isDark
//                                 ? Reusable.getDarkModeBlack()
//                                 : Reusable.getWhite(),
//                           ),
//                         ),
//                         SizedBox(width: 5),
//                         // 🔹 Title text
//                         Text(
//                           "Cricket Scoreboard",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                             color: isDark
//                                 ? Reusable.getDarkModeBlack()
//                                 : Reusable.getWhite(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // 🔹 White rounded bottom sheet (Main content area)
//               Positioned(
//                 top:
//                     (MediaQuery.of(context).size.height) *
//                     0.097192, // pushes down from top
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? Reusable.getDarkModeBlack()
//                         : Reusable.getWhite(),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(50),
//                       topRight: Radius.circular(50),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color.fromRGBO(0, 0, 0, 0.25),
//                         spreadRadius: 0,
//                         blurRadius: 10,
//                         offset: Offset(0, 0),
//                       ),
//                     ],
//                   ),

//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           height: Reusable.getDeviceHeight(context, H: 20),
//                         ),

//                         Container(
//                           width: Reusable.getDeviceWidth(context, W: 388),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? Reusable.getDarkModeGrey()
//                                 : Reusable.getWhite(),
//                             borderRadius: BorderRadius.circular(
//                               Reusable.getDeviceWidth(context, W: 20),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 blurRadius: 2,
//                                 color: Color.fromRGBO(0, 0, 0, 0.25),
//                               ),
//                             ],
//                           ),

//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   top: Reusable.getDeviceHeight(context, H: 10),
//                                   left: Reusable.getDeviceWidth(context, W: 15),
//                                 ),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     "Team Details",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: isDark
//                                           ? Reusable.getLightGreen()
//                                           : Reusable.getBlack(),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(
//                                 height: Reusable.getDeviceHeight(
//                                   context,
//                                   H: 10,
//                                 ),
//                               ),

//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   bottom: Reusable.getDeviceHeight(
//                                     context,
//                                     H: 15,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 60,
//                                       ),
//                                       width: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 358,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(
//                                           Reusable.getDeviceWidth(
//                                             context,
//                                             W: 30,
//                                           ),
//                                         ),
//                                       ),
// child: TextField(
//   style: TextStyle(
//     color: isDark
//         ? Reusable.getLightGreen()
//         : Reusable.getDarkGrey(),
//   ),
//   cursorColor: isDark
//       ? Reusable.getLightGreen()
//       : Reusable.getGreen(),
//   decoration: InputDecoration(
//     hintText: "Search by Name",
//     hintStyle: TextStyle(
//       color: isDark
//           ? Reusable.getLightGreen()
//           : Reusable.getDarkGrey(),
//     ),
//     filled: true,
//     fillColor: isDark
//         ? Reusable.getDarkModeBlack()
//         : Reusable.getWhite(), // background color
//     // 🔍 Search icon
//     suffixIcon: Icon(
//       Icons.search,
//       color: isDark
//           ? Reusable.getLightGreen()
//           : Reusable.getGreen(),
//       size: Reusable.getDeviceWidth(
//         context,
//         W: 30,
//       ),
//     ),

//     // Borders
//     enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(
//         color: isDark
//             ? Reusable.getLightGrey()
//             : Reusable.getLightGrey(),
//         width: 1,
//       ),
//       borderRadius: BorderRadius.circular(
//         Reusable.getDeviceWidth(
//           context,
//           W: 30,
//         ),
//       ),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(
//         color: isDark
//             ? Reusable.getLightGreen()
//             : Reusable.getGreen(),
//         width: 1,
//       ),
//       borderRadius: BorderRadius.circular(
//         Reusable.getDeviceWidth(
//           context,
//           W: 30,
//         ),
//       ),
//     ),
//     errorBorder: OutlineInputBorder(
//       borderSide: const BorderSide(
//         color: Colors.orange,
//         width: 2,
//       ),
//       borderRadius: BorderRadius.circular(
//         12,
//       ),
//     ),
//     focusedErrorBorder:
//         OutlineInputBorder(
//           borderSide: const BorderSide(
//             color: Colors.purple,
//             width: 2,
//           ),
//           borderRadius:
//               BorderRadius.circular(12),
//         ),
//   ),
// ),
// ),

//                                     SizedBox(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 10,
//                                       ),
//                                     ),

//                                     Container(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 60,
//                                       ),
//                                       width: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 358,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(
//                                           Reusable.getDeviceWidth(
//                                             context,
//                                             W: 30,
//                                           ),
//                                         ),
//                                       ),
//                                       child: TextField(
//                                         style: TextStyle(
//                                           color: isDark
//                                               ? Reusable.getLightGreen()
//                                               : Reusable.getDarkGrey(),
//                                         ),
//                                         cursorColor: isDark
//                                             ? Reusable.getLightGreen()
//                                             : Reusable.getGreen(),
//                                         decoration: InputDecoration(
//                                           hintText: "Search by Name",
//                                           hintStyle: TextStyle(
//                                             color: isDark
//                                                 ? Reusable.getLightGreen()
//                                                 : Reusable.getDarkGrey(),
//                                           ),
//                                           filled: true,
//                                           fillColor: isDark
//                                               ? Reusable.getDarkModeBlack()
//                                               : Reusable.getWhite(), // background color
//                                           // 🔍 Search icon
//                                           suffixIcon: Icon(
//                                             Icons.search,
//                                             color: isDark
//                                                 ? Reusable.getLightGreen()
//                                                 : Reusable.getGreen(),
//                                             size: Reusable.getDeviceWidth(
//                                               context,
//                                               W: 30,
//                                             ),
//                                           ),

//                                           // Borders
//                                           enabledBorder: OutlineInputBorder(
//                                             borderSide: BorderSide(
//                                               color: isDark
//                                                   ? Reusable.getLightGrey()
//                                                   : Reusable.getLightGrey(),
//                                               width: 1,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               Reusable.getDeviceWidth(
//                                                 context,
//                                                 W: 30,
//                                               ),
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderSide: BorderSide(
//                                               color: isDark
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getGreen(),
//                                               width: 1,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               Reusable.getDeviceWidth(
//                                                 context,
//                                                 W: 30,
//                                               ),
//                                             ),
//                                           ),
//                                           errorBorder: OutlineInputBorder(
//                                             borderSide: const BorderSide(
//                                               color: Colors.orange,
//                                               width: 2,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           focusedErrorBorder:
//                                               OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                   color: Colors.purple,
//                                                   width: 2,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(
//                           height: Reusable.getDeviceHeight(context, H: 20),
//                         ),

//                         Container(
//                           width: Reusable.getDeviceWidth(context, W: 388),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? Reusable.getDarkModeGrey()
//                                 : Reusable.getWhite(),
//                             borderRadius: BorderRadius.circular(
//                               Reusable.getDeviceWidth(context, W: 20),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 blurRadius: 2,
//                                 color: Color.fromRGBO(0, 0, 0, 0.25),
//                               ),
//                             ],
//                           ),

//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   top: Reusable.getDeviceHeight(context, H: 10),
//                                   left: Reusable.getDeviceWidth(context, W: 15),
//                                 ),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     "Overs & Team Size",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: isDark
//                                           ? Reusable.getLightGreen()
//                                           : Reusable.getBlack(),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(
//                                 height: Reusable.getDeviceHeight(
//                                   context,
//                                   H: 10,
//                                 ),
//                               ),

//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       selectedOver = "5 Overs";
//                                       selectedOverNo = 5;
//                                       setState(() {});
//                                     },
//                                     child: Container(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 40,
//                                       ),
//                                       width: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 85,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? (selectedOver == "5 Overs")
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkModeBlack()
//                                             : (selectedOver == "5 Overs")
//                                             ? Reusable.getGreen()
//                                             : Reusable.getWhite(),

//                                         border: Border.all(
//                                           color: isDark
//                                               ? Reusable.getLightGreen()
//                                               : Reusable.getGreen(),
//                                         ),
//                                         borderRadius: BorderRadius.circular(
//                                           Reusable.getDeviceWidth(
//                                             context,
//                                             W: 20,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           "5 Overs",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: isDark
//                                                 ? (selectedOver == "5 Overs")
//                                                       ? Reusable.getDarkModeBlack()
//                                                       : Reusable.getLightGreen()
//                                                 : (selectedOver == "5 Overs")
//                                                 ? Reusable.getWhite()
//                                                 : Reusable.getGreen(),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),

//                                   SizedBox(
//                                     width: Reusable.getDeviceWidth(
//                                       context,
//                                       W: 10,
//                                     ),
//                                   ),

//                                   GestureDetector(
//                                     onTap: () {
//                                       selectedOver = "10 Overs";
//                                       selectedOverNo = 10;
//                                       setState(() {});
//                                     },
//                                     child: Container(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 40,
//                                       ),
//                                       width: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 85,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? (selectedOver == "10 Overs")
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkModeBlack()
//                                             : (selectedOver == "10 Overs")
//                                             ? Reusable.getGreen()
//                                             : Reusable.getWhite(),

//                                         border: Border.all(
//                                           color: isDark
//                                               ? Reusable.getLightGreen()
//                                               : Reusable.getGreen(),
//                                         ),
//                                         borderRadius: BorderRadius.circular(
//                                           Reusable.getDeviceWidth(
//                                             context,
//                                             W: 20,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           "10 Overs",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: isDark
//                                                 ? (selectedOver == "10 Overs")
//                                                       ? Reusable.getDarkModeBlack()
//                                                       : Reusable.getLightGreen()
//                                                 : (selectedOver == "10 Overs")
//                                                 ? Reusable.getWhite()
//                                                 : Reusable.getGreen(),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),

//                                   SizedBox(
//                                     width: Reusable.getDeviceWidth(
//                                       context,
//                                       W: 10,
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       selectedOver = "20 Overs";
//                                       selectedOverNo = 20;
//                                       setState(() {});
//                                     },
//                                     child: Container(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 40,
//                                       ),
//                                       width: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 85,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? (selectedOver == "20 Overs")
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkModeBlack()
//                                             : (selectedOver == "20 Overs")
//                                             ? Reusable.getGreen()
//                                             : Reusable.getWhite(),

//                                         border: Border.all(
//                                           color: isDark
//                                               ? Reusable.getLightGreen()
//                                               : Reusable.getGreen(),
//                                         ),
//                                         borderRadius: BorderRadius.circular(
//                                           Reusable.getDeviceWidth(
//                                             context,
//                                             W: 20,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           "20 Overs",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: isDark
//                                                 ? (selectedOver == "20 Overs")
//                                                       ? Reusable.getDarkModeBlack()
//                                                       : Reusable.getLightGreen()
//                                                 : (selectedOver == "20 Overs")
//                                                 ? Reusable.getWhite()
//                                                 : Reusable.getGreen(),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),

//                                   SizedBox(
//                                     width: Reusable.getDeviceWidth(
//                                       context,
//                                       W: 10,
//                                     ),
//                                   ),

//                                   GestureDetector(
//                                     onTap: () {
//                                       selectedOver = "custom";
//                                       selectedOverNo = 10;
//                                       setState(() {});
//                                     },
//                                     child: Container(
//                                       height: Reusable.getDeviceHeight(
//                                         context,
//                                         H: 40,
//                                       ),
//                                       width: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 85,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? (selectedOver == "custom")
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkModeBlack()
//                                             : (selectedOver == "custom")
//                                             ? Reusable.getGreen()
//                                             : Reusable.getWhite(),

//                                         border: Border.all(
//                                           color: isDark
//                                               ? Reusable.getLightGreen()
//                                               : Reusable.getGreen(),
//                                         ),
//                                         borderRadius: BorderRadius.circular(
//                                           Reusable.getDeviceWidth(
//                                             context,
//                                             W: 20,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           "Custom",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: isDark
//                                                 ? (selectedOver == "custom")
//                                                       ? Reusable.getDarkModeBlack()
//                                                       : Reusable.getLightGreen()
//                                                 : (selectedOver == "custom")
//                                                 ? Reusable.getWhite()
//                                                 : Reusable.getGreen(),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: Reusable.getDeviceHeight(
//                                   context,
//                                   H: 10,
//                                 ),
//                               ),

//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   IconButton(
//                                     onPressed: () {
//                                       if (totalPlayers < 11) {
//                                         totalPlayers++;
//                                         setState(() {});
//                                       }
//                                     },
//                                     icon: Icon(
//                                       Icons.add_circle_outline,
//                                       size: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 30,
//                                       ),
//                                       color: isDark
//                                           ? Reusable.getLightGreen()
//                                           : Reusable.getDarkGrey(),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: Reusable.getDeviceWidth(
//                                       context,
//                                       W: 5,
//                                     ),
//                                   ),
//                                   Text(
//                                     "$totalPlayers Players",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w400,
//                                       color: isDark
//                                           ? Reusable.getLightGrey()
//                                           : Reusable.getDarkGrey(),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: Reusable.getDeviceWidth(
//                                       context,
//                                       W: 5,
//                                     ),
//                                   ),

//                                   IconButton(
//                                     onPressed: () {
//                                       if (totalPlayers > 2) {
//                                         totalPlayers--;
//                                         setState(() {});
//                                       }
//                                     },
//                                     icon: Icon(
//                                       Icons.remove_circle_outline,
//                                       size: Reusable.getDeviceWidth(
//                                         context,
//                                         W: 30,
//                                       ),
//                                       color: isDark
//                                           ? Reusable.getLightGreen()
//                                           : Reusable.getDarkGrey(),
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               (selectedOver == "custom")
//                                   ? Padding(
//                                       padding: EdgeInsets.only(
//                                         bottom: Reusable.getDeviceHeight(
//                                           context,
//                                           H: 10,
//                                         ),
//                                       ),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           IconButton(
//                                             onPressed: () {

//                                               if (totalOvers < 50) {
//                                                 totalOvers += 5;
//                                               }
//                                               selectedOverNo = totalOvers;
//                                               setState(() {});
//                                             },
//                                             icon: Icon(
//                                               Icons.add_circle_outline,
//                                               size: Reusable.getDeviceWidth(
//                                                 context,
//                                                 W: 30,
//                                               ),
//                                               color: isDark
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkGrey(),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: Reusable.getDeviceWidth(
//                                               context,
//                                               W: 5,
//                                             ),
//                                           ),
//                                           Text(
//                                             "$totalOvers Overs",
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w400,
//                                               color: isDark
//                                                   ? Reusable.getLightGrey()
//                                                   : Reusable.getDarkGrey(),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: Reusable.getDeviceWidth(
//                                               context,
//                                               W: 5,
//                                             ),
//                                           ),

//                                           IconButton(
//                                             onPressed: () {
//                                               if (totalOvers > 5) {
//                                                 totalOvers -= 5;
//                                               }
//                                               selectedOverNo = totalOvers;
//                                               setState(() {});
//                                             },
//                                             icon: Icon(
//                                               Icons.remove_circle_outline,
//                                               size: Reusable.getDeviceWidth(
//                                                 context,
//                                                 W: 30,
//                                               ),
//                                               color: isDark
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkGrey(),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : SizedBox(),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: Reusable.getDeviceHeight(context, H: 20),
//                         ),

//                         Container(
//                           width: Reusable.getDeviceWidth(context, W: 388),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? Reusable.getDarkModeGrey()
//                                 : Reusable.getWhite(),
//                             borderRadius: BorderRadius.circular(
//                               Reusable.getDeviceWidth(context, W: 20),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 blurRadius: 2,
//                                 color: Color.fromRGBO(0, 0, 0, 0.25),
//                               ),
//                             ],
//                           ),

//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   top: Reusable.getDeviceHeight(context, H: 10),
//                                   left: Reusable.getDeviceWidth(context, W: 15),
//                                 ),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     "Player Details (Team A)",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: isDark
//                                           ? Reusable.getLightGreen()
//                                           : Reusable.getBlack(),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(
//                                 height: Reusable.getDeviceHeight(
//                                   context,
//                                   H: 10,
//                                 ),
//                               ),

//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   bottom: Reusable.getDeviceHeight(
//                                     context,
//                                     H: 15,
//                                   ),
//                                 ),
//                                 child: ListView.builder(
//                                   physics: NeverScrollableScrollPhysics(),
//                                   padding: EdgeInsets.zero,
//                                   shrinkWrap: true,
//                                   itemCount: totalPlayers,
//                                   itemBuilder: (BuildContext context, int index) {
//                                     return Column(
//                                       children: [
//                                         Container(
//                                           height: Reusable.getDeviceHeight(
//                                             context,
//                                             H: 60,
//                                           ),
//                                           width: Reusable.getDeviceWidth(
//                                             context,
//                                             W: 358,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(
//                                               Reusable.getDeviceWidth(
//                                                 context,
//                                                 W: 30,
//                                               ),
//                                             ),
//                                           ),
//                                           child: TextField(
//                                             controller: teamAPlayers[index],
//                                             style: TextStyle(
//                                               color: isDark
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkGrey(),
//                                             ),
//                                             cursorColor: isDark
//                                                 ? Reusable.getLightGreen()
//                                                 : Reusable.getGreen(),
//                                             decoration: InputDecoration(
//                                               hintText: "Search by Name",
//                                               hintStyle: TextStyle(
//                                                 color: isDark
//                                                     ? Reusable.getLightGreen()
//                                                     : Reusable.getDarkGrey(),
//                                               ),
//                                               filled: true,
//                                               fillColor: isDark
//                                                   ? Reusable.getDarkModeBlack()
//                                                   : Reusable.getWhite(), // background color
//                                               // 🔍 Search icon
//                                               suffixIcon: Icon(
//                                                 Icons.person_add_alt_1_rounded,
//                                                 color: isDark
//                                                     ? Reusable.getLightGreen()
//                                                     : Reusable.getGreen(),
//                                                 size: Reusable.getDeviceWidth(
//                                                   context,
//                                                   W: 30,
//                                                 ),
//                                               ),

//                                               // Borders
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: isDark
//                                                       ? Reusable.getLightGrey()
//                                                       : Reusable.getLightGrey(),
//                                                   width: 1,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       Reusable.getDeviceWidth(
//                                                         context,
//                                                         W: 30,
//                                                       ),
//                                                     ),
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: isDark
//                                                       ? Reusable.getLightGreen()
//                                                       : Reusable.getGreen(),
//                                                   width: 1,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       Reusable.getDeviceWidth(
//                                                         context,
//                                                         W: 30,
//                                                       ),
//                                                     ),
//                                               ),
//                                               errorBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                   color: Colors.orange,
//                                                   width: 2,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               focusedErrorBorder:
//                                                   OutlineInputBorder(
//                                                     borderSide:
//                                                         const BorderSide(
//                                                           color: Colors.purple,
//                                                           width: 2,
//                                                         ),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           12,
//                                                         ),
//                                                   ),
//                                             ),
//                                           ),
//                                         ),

//                                         SizedBox(
//                                           height: Reusable.getDeviceHeight(
//                                             context,
//                                             H: 10,
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(
//                           height: Reusable.getDeviceHeight(context, H: 20),
//                         ),

//                         Container(
//                           width: Reusable.getDeviceWidth(context, W: 388),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? Reusable.getDarkModeGrey()
//                                 : Reusable.getWhite(),
//                             borderRadius: BorderRadius.circular(
//                               Reusable.getDeviceWidth(context, W: 20),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 blurRadius: 2,
//                                 color: Color.fromRGBO(0, 0, 0, 0.25),
//                               ),
//                             ],
//                           ),

//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   top: Reusable.getDeviceHeight(context, H: 10),
//                                   left: Reusable.getDeviceWidth(context, W: 15),
//                                 ),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     "Player Details (Team B)",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: isDark
//                                           ? Reusable.getLightGreen()
//                                           : Reusable.getBlack(),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(
//                                 height: Reusable.getDeviceHeight(
//                                   context,
//                                   H: 10,
//                                 ),
//                               ),

//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   bottom: Reusable.getDeviceHeight(
//                                     context,
//                                     H: 15,
//                                   ),
//                                 ),
//                                 child: ListView.builder(
//                                   physics: NeverScrollableScrollPhysics(),
//                                   padding: EdgeInsets.zero,
//                                   shrinkWrap: true,
//                                   itemCount: totalPlayers,
//                                   itemBuilder: (BuildContext context, int index) {
//                                     return Column(
//                                       children: [
//                                         Container(
//                                           height: Reusable.getDeviceHeight(
//                                             context,
//                                             H: 60,
//                                           ),
//                                           width: Reusable.getDeviceWidth(
//                                             context,
//                                             W: 358,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(
//                                               Reusable.getDeviceWidth(
//                                                 context,
//                                                 W: 30,
//                                               ),
//                                             ),
//                                           ),
//                                           child: TextField(
//                                             controller: teamBPlayers[index],
//                                             style: TextStyle(
//                                               color: isDark
//                                                   ? Reusable.getLightGreen()
//                                                   : Reusable.getDarkGrey(),
//                                             ),
//                                             cursorColor: isDark
//                                                 ? Reusable.getLightGreen()
//                                                 : Reusable.getGreen(),
//                                             decoration: InputDecoration(
//                                               hintText: "Search by Name",
//                                               hintStyle: TextStyle(
//                                                 color: isDark
//                                                     ? Reusable.getLightGreen()
//                                                     : Reusable.getDarkGrey(),
//                                               ),
//                                               filled: true,
//                                               fillColor: isDark
//                                                   ? Reusable.getDarkModeBlack()
//                                                   : Reusable.getWhite(), // background color
//                                               // 🔍 Search icon
//                                               suffixIcon: Icon(
//                                                 Icons.person_add_alt_1_rounded,
//                                                 color: isDark
//                                                     ? Reusable.getLightGreen()
//                                                     : Reusable.getGreen(),
//                                                 size: Reusable.getDeviceWidth(
//                                                   context,
//                                                   W: 30,
//                                                 ),
//                                               ),

//                                               // Borders
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: isDark
//                                                       ? Reusable.getLightGrey()
//                                                       : Reusable.getLightGrey(),
//                                                   width: 1,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       Reusable.getDeviceWidth(
//                                                         context,
//                                                         W: 30,
//                                                       ),
//                                                     ),
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: isDark
//                                                       ? Reusable.getLightGreen()
//                                                       : Reusable.getGreen(),
//                                                   width: 1,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       Reusable.getDeviceWidth(
//                                                         context,
//                                                         W: 30,
//                                                       ),
//                                                     ),
//                                               ),
//                                               errorBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                   color: Colors.orange,
//                                                   width: 2,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               focusedErrorBorder:
//                                                   OutlineInputBorder(
//                                                     borderSide:
//                                                         const BorderSide(
//                                                           color: Colors.purple,
//                                                           width: 2,
//                                                         ),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           12,
//                                                         ),
//                                                   ),
//                                             ),
//                                           ),
//                                         ),

//                                         SizedBox(
//                                           height: Reusable.getDeviceHeight(
//                                             context,
//                                             H: 10,
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Padding(
//                           padding: EdgeInsets.only(
//                             bottom: Reusable.getDeviceHeight(context, H: 40),
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               if (teamAPlayers.isNotEmpty) {
//                                 for (int i = 0; i < teamAPlayers.length; i++) {
//                                   log(teamAPlayers[i]!.text);
//                                   log(teamBPlayers[i]!.text);
//                                 }
//                               }
//                               log("$selectedOverNo");
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) {
//                                     return CricketScoreboard(teamAPlayers: teamAPlayers, teamBPlayers: teamBPlayers,totalOvers: selectedOverNo, totalPlayers: totalPlayers,);
//                                   },
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               height: Reusable.getDeviceHeight(context, H: 60),
//                               width: Reusable.getDeviceWidth(context, W: 388),
//                               decoration: BoxDecoration(
//                                 color: isDark
//                                     ? Reusable.getLightGreen()
//                                     : Reusable.getGreen(),
//                                 borderRadius: BorderRadius.circular(
//                                   Reusable.getDeviceWidth(context, W: 30),
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "START GAME",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: isDark
//                                           ? Reusable.getDarkModeBlack()
//                                           : Reusable.getWhite(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// paste this entire file into lib/main.dart
import 'dart:convert';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';

class CricketApp extends StatelessWidget {
  const CricketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchController()..loadFromStorage(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = context.watch<MatchController>();
    if (!mc.isConfigured) return const SetupScreen();
    return const ScoreboardScreen();
  }
}

// ============================= MODELS =============================

enum Format { t20, odi }

enum InningsNumber { first, second }

enum Dismissal { bowledCaughtLBW, runOutHitWicket }

class Player {
  final String name;
  int runs;
  int ballsFaced;
  int fours;
  int sixes;
  bool out;
  String dismissalNote; // e.g., b Smith, c Doe, run out

  Player({
    required this.name,
    this.runs = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.out = false,
    this.dismissalNote = "",
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'runs': runs,
    'ballsFaced': ballsFaced,
    'fours': fours,
    'sixes': sixes,
    'out': out,
    'dismissalNote': dismissalNote,
  };

  factory Player.fromJson(Map<String, dynamic> j) => Player(
    name: j['name'],
    runs: j['runs'],
    ballsFaced: j['ballsFaced'],
    fours: j['fours'],
    sixes: j['sixes'],
    out: j['out'],
    dismissalNote: j['dismissalNote'] ?? "",
  );
}

class BowlerStats {
  final String name;
  int balls; // legal balls
  int runsConceded; // includes wides/noballs etc.
  int wickets;

  BowlerStats({
    required this.name,
    this.balls = 0,
    this.runsConceded = 0,
    this.wickets = 0,
  });

  double get overs => balls ~/ 6 + (balls % 6) / 10.0;
  double get economy => balls == 0 ? 0 : runsConceded / (balls / 6);

  Map<String, dynamic> toJson() => {
    'name': name,
    'balls': balls,
    'runsConceded': runsConceded,
    'wickets': wickets,
  };

  factory BowlerStats.fromJson(Map<String, dynamic> j) => BowlerStats(
    name: j['name'],
    balls: j['balls'],
    runsConceded: j['runsConceded'],
    wickets: j['wickets'],
  );
}

class Team {
  final String name;
  final List<Player> players;

  Team({required this.name, required this.players});

  Map<String, dynamic> toJson() => {
    'name': name,
    'players': players.map((e) => e.toJson()).toList(),
  };

  factory Team.fromJson(Map<String, dynamic> j) => Team(
    name: j['name'],
    players: (j['players'] as List).map((e) => Player.fromJson(e)).toList(),
  );
}

class ExtrasBreakdown {
  int wides;
  int noBalls;
  int byes;
  int legByes;

  ExtrasBreakdown({
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
  });

  int get total => wides + noBalls + byes + legByes;

  Map<String, dynamic> toJson() => {
    'wides': wides,
    'noBalls': noBalls,
    'byes': byes,
    'legByes': legByes,
  };

  factory ExtrasBreakdown.fromJson(Map<String, dynamic> j) => ExtrasBreakdown(
    wides: j['wides'],
    noBalls: j['noBalls'],
    byes: j['byes'],
    legByes: j['legByes'],
  );
}

class Innings {
  final Team batting;
  final Team bowling;
  int runs;
  int wickets;
  int legalBalls; // total legal balls bowled
  ExtrasBreakdown extras;
  int strikerIndex; // index in batting.players
  int nonStrikerIndex;
  int? currentBowlerIndex; // index in bowling.players
  bool freeHitNextLegal;
  Map<String, BowlerStats> bowlers; // name -> stats

  Innings({
    required this.batting,
    required this.bowling,
    this.runs = 0,
    this.wickets = 0,
    this.legalBalls = 0,
    ExtrasBreakdown? extras,
    this.strikerIndex = 0,
    this.nonStrikerIndex = 1,
    this.currentBowlerIndex,
    this.freeHitNextLegal = false,
    Map<String, BowlerStats>? bowlers,
  }) : extras = extras ?? ExtrasBreakdown(),
       bowlers = bowlers ?? {};

  int get oversCompleted => legalBalls ~/ 6;
  int get ballsIntoOver => legalBalls % 6;
  String get oversString => "$oversCompleted.$ballsIntoOver";
  double get crr => legalBalls == 0 ? 0 : runs / (legalBalls / 6);

  Player get striker => batting.players[strikerIndex];
  Player get nonStriker => batting.players[nonStrikerIndex];
  Player get currentBowler => bowling.players[currentBowlerIndex ?? 0];

  Map<String, dynamic> toJson() => {
    'batting': batting.toJson(),
    'bowling': bowling.toJson(),
    'runs': runs,
    'wickets': wickets,
    'legalBalls': legalBalls,
    'extras': extras.toJson(),
    'strikerIndex': strikerIndex,
    'nonStrikerIndex': nonStrikerIndex,
    'currentBowlerIndex': currentBowlerIndex,
    'freeHitNextLegal': freeHitNextLegal,
    'bowlers': bowlers.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory Innings.fromJson(Map<String, dynamic> j) => Innings(
    batting: Team.fromJson(j['batting']),
    bowling: Team.fromJson(j['bowling']),
    runs: j['runs'],
    wickets: j['wickets'],
    legalBalls: j['legalBalls'],
    extras: ExtrasBreakdown.fromJson(j['extras']),
    strikerIndex: j['strikerIndex'],
    nonStrikerIndex: j['nonStrikerIndex'],
    currentBowlerIndex: j['currentBowlerIndex'],
    freeHitNextLegal: j['freeHitNextLegal'],
    bowlers: (j['bowlers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, BowlerStats.fromJson(v)),
    ),
  );
}

class MatchModel {
  final Team teamA;
  final Team teamB;
  final Format format;
  final int oversLimit; // per innings
  InningsNumber inningsNumber;
  Innings innings1;
  Innings? innings2;

  MatchModel({
    required this.teamA,
    required this.teamB,
    required this.format,
    required this.oversLimit,
    required this.innings1,
    this.innings2,
    this.inningsNumber = InningsNumber.first,
  });

  bool get isSecondInnings => inningsNumber == InningsNumber.second;

  int? get target => isSecondInnings ? innings1.runs + 1 : null;

  Map<String, dynamic> toJson() => {
    'teamA': teamA.toJson(),
    'teamB': teamB.toJson(),
    'format': format.name,
    'oversLimit': oversLimit,
    'inningsNumber': inningsNumber.name,
    'innings1': innings1.toJson(),
    'innings2': innings2?.toJson(),
  };

  factory MatchModel.fromJson(Map<String, dynamic> j) {
    final format = j['format'] == 'odi' ? Format.odi : Format.t20;
    final innNum = j['inningsNumber'] == 'second'
        ? InningsNumber.second
        : InningsNumber.first;
    return MatchModel(
      teamA: Team.fromJson(j['teamA']),
      teamB: Team.fromJson(j['teamB']),
      format: format,
      oversLimit: j['oversLimit'],
      innings1: Innings.fromJson(j['innings1']),
      innings2: j['innings2'] == null ? null : Innings.fromJson(j['innings2']),
      inningsNumber: innNum,
    );
  }
}

// What happened on a ball (for undo)
class BallEvent {
  final String
  description; // e.g., "1 run", "wide+1", "no-ball + 2 runs", "wicket"
  final Map<String, dynamic>
  snapshotBefore; // whole match snapshot to allow precise undo

  BallEvent({required this.description, required this.snapshotBefore});
}

// ============================= CONTROLLER =============================

class MatchController extends ChangeNotifier {
  static const _storageKey = 'cricket_match_state_v1';
  static const _storageResultKey = 'cricket_match_result_v1';

  MatchModel? _match;
  final List<BallEvent> _history = [];
  bool _loading = false;

  String? _matchResult; // null while match in progress, otherwise result text

  bool get isConfigured => _match != null;
  bool get isLoading => _loading;
  MatchModel? get match => _match;
  String? get matchResult => _matchResult;
  bool get matchOver => _matchResult != null;

  // Setup
  void configure({
    required String teamAName,
    required String teamBName,
    required List<String> teamAPlayers,
    required List<String> teamBPlayers,
    required Format format,
    required int oversLimit,
  }) {
    if (oversLimit <= 0) {
      // programmatic guard against zero / negative overs
      throw ArgumentError.value(
        oversLimit,
        'oversLimit',
        'Overs must be greater than zero',
      );
    }

    final teamA = Team(
      name: teamAName,
      players: teamAPlayers.map((e) => Player(name: e)).toList(),
    );
    final teamB = Team(
      name: teamBName,
      players: teamBPlayers.map((e) => Player(name: e)).toList(),
    );

    // Toss: Team A bats first by default; you can swap in UI during setup
    final innings1 = Innings(batting: teamA, bowling: teamB);

    _match = MatchModel(
      teamA: teamA,
      teamB: teamB,
      format: format,
      oversLimit: oversLimit,
      innings1: innings1,
    );

    _matchResult = null; // clear any previous result
    _history.clear();
    _persist();
    notifyListeners();
  }

  void swapFirstBatting() {
    if (_match == null) return;
    if (_match!.inningsNumber != InningsNumber.first) return;
    final a = _match!.teamA;
    final b = _match!.teamB;
    final newInnings1 = Innings(
      batting: _match!.innings1.batting == a ? b : a,
      bowling: _match!.innings1.bowling == b ? a : b,
    );
    _match = MatchModel(
      teamA: a,
      teamB: b,
      format: _match!.format,
      oversLimit: _match!.oversLimit,
      innings1: newInnings1,
    );
    _persist();
    notifyListeners();
  }

  // Helper serialization
  Map<String, dynamic> _snapshot() => _match == null ? {} : _match!.toJson();
  void _restore(Map<String, dynamic> json) {
    _match = MatchModel.fromJson(json);
  }

  // Ball application methods
  void _pushHistory(String desc) {
    _history.add(BallEvent(description: desc, snapshotBefore: _snapshot()));
  }

  bool get canUndo => _history.isNotEmpty;
  void undo() {
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    _restore(last.snapshotBefore);
    _matchResult = null; // undo might revert match result
    _persist();
    notifyListeners();
  }

  Innings get _currentInnings =>
      (_match!.isSecondInnings ? _match!.innings2! : _match!.innings1);

  void selectBowler(int bowlerIndex) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    // prevent same bowler bowling consecutive overs
    final lastBowler = inn.currentBowlerIndex;
    if (inn.ballsIntoOver == 0 &&
        lastBowler != null &&
        lastBowler == bowlerIndex &&
        inn.oversCompleted > 0) {
      // ignore selection — UI can suggest changing
      return;
    }
    _pushHistory('select bowler');
    inn.currentBowlerIndex = bowlerIndex;
    _persist();
    notifyListeners();
  }

  // Public API for scoring buttons
  void scoreRuns(int runs) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    _pushHistory('runs $runs');

    final striker = inn.striker;
    striker.runs += runs;
    striker.ballsFaced += 1;
    if (runs == 4) striker.fours += 1;
    if (runs == 6) striker.sixes += 1;

    _creditBowler(runs);

    inn.runs += runs;
    _incrementLegalBallAndHandleFreeHit(inn);

    _maybeSwapStrike(runs);
    _maybeEndOverAndRotateStrike();
    _checkInningsEnd();

    _persist();
    notifyListeners();
  }

  void wide(int runsExtra) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    _pushHistory('wide +$runsExtra');
    inn.runs += runsExtra;
    inn.extras.wides += runsExtra;
    _creditBowler(runsExtra, legalBall: false);

    // Wides can finish a chase immediately (even though not a legal ball)
    _maybeFinishOnChase();
    _persist();
    notifyListeners();
  }

  void noBall({int runsOffBat = 0}) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    _pushHistory('no-ball +1, bat+$runsOffBat');

    final total = 1 + runsOffBat;
    inn.runs += total;
    inn.extras.noBalls += 1;
    _creditBowler(total, legalBall: false);

    // If runsOffBat > 0, they are credited to batsman but ball doesn't count
    if (runsOffBat > 0) {
      final striker = inn.striker;
      striker.runs += runsOffBat;
      if (runsOffBat == 4) striker.fours += 1;
      if (runsOffBat == 6) striker.sixes += 1;
      // ballsFaced not incremented for no-ball
      // strike change for runs off bat on NB: yes, odd runs swap strike though ball not counted.
      _maybeSwapStrike(runsOffBat);
    }

    // Set Free Hit for next legal ball
    inn.freeHitNextLegal = true;

    // No-ball can finish chase immediately
    _maybeFinishOnChase();
    _persist();
    notifyListeners();
  }

  void bye(int runs) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    _pushHistory('bye $runs');

    inn.runs += runs;
    inn.extras.byes += runs;
    _creditBowler(runs);

    // batsman does not get runs, but ball counts to striker
    inn.striker.ballsFaced += 1;

    _incrementLegalBallAndHandleFreeHit(inn);
    _maybeSwapStrike(runs);
    _maybeEndOverAndRotateStrike();
    _checkInningsEnd();
    _persist();
    notifyListeners();
  }

  void legBye(int runs) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    _pushHistory('leg-bye $runs');

    inn.runs += runs;
    inn.extras.legByes += runs;
    _creditBowler(runs);

    inn.striker.ballsFaced += 1;

    _incrementLegalBallAndHandleFreeHit(inn);
    _maybeSwapStrike(runs);
    _maybeEndOverAndRotateStrike();
    _checkInningsEnd();
    _persist();
    notifyListeners();
  }

  void wicket({required Dismissal dismissal}) {
    if (_match == null || matchOver) return;
    final inn = _currentInnings;
    _pushHistory('wicket');

    final onFreeHit = inn.freeHitNextLegal;

    // For Free Hit, only run-out/hit-wicket allowed
    if (onFreeHit && dismissal == Dismissal.bowledCaughtLBW) {
      // Not allowed; ignore
      return;
    }

    // credit ball
    _creditBowler(0, wicket: dismissal == Dismissal.bowledCaughtLBW);

    // Update batsman and innings
    inn.striker.ballsFaced += 1;
    if (dismissal == Dismissal.bowledCaughtLBW) {
      inn.striker.out = true;
      inn.striker.dismissalNote = 'Out';
    } else {
      // run out / hit wicket during free hit or normal legal ball
      inn.striker.out = true;
      inn.striker.dismissalNote = 'Run Out/Hit Wicket';
    }

    inn.wickets += 1;
    _incrementLegalBallAndHandleFreeHit(inn);

    // Bring next batter if any
    final nextIndex = _nextBatterIndex(inn);
    if (nextIndex != null) {
      inn.strikerIndex = nextIndex; // striker replaced
    }

    _maybeEndOverAndRotateStrike();
    _checkInningsEnd();

    _persist();
    notifyListeners();
  }

  // helpers
  void _creditBowler(int runs, {bool legalBall = true, bool wicket = false}) {
    final inn = _currentInnings;
    final bowler = inn.currentBowler;
    final stat = inn.bowlers[bowler.name] ?? BowlerStats(name: bowler.name);
    stat.runsConceded += runs;
    if (legalBall) stat.balls += 1;
    if (wicket) stat.wickets += 1;
    inn.bowlers[bowler.name] = stat;
  }

  void _incrementLegalBallAndHandleFreeHit(Innings inn) {
    // legal ball bowled
    final wasFreeHit = inn.freeHitNextLegal;
    if (wasFreeHit) {
      // the current ball was the free hit
      inn.freeHitNextLegal = false;
    }
    inn.legalBalls += 1;
  }

  void _maybeSwapStrike(int runs) {
    if (runs % 2 == 1) {
      _swapStrike();
    }
  }

  void _maybeEndOverAndRotateStrike() {
    final inn = _currentInnings;
    if (inn.legalBalls % 6 == 0) {
      _swapStrike();
      // prompt to change bowler in UI (no automatic change here)
    }
  }

  void _swapStrike() {
    final inn = _currentInnings;
    final a = inn.strikerIndex;
    inn.strikerIndex = inn.nonStrikerIndex;
    inn.nonStrikerIndex = a;
  }

  int? _nextBatterIndex(Innings inn) {
    for (int i = 0; i < inn.batting.players.length; i++) {
      if (i != inn.strikerIndex &&
          i != inn.nonStrikerIndex &&
          !inn.batting.players[i].out) {
        return i;
      }
    }
    return null;
  }

  void _checkInningsEnd() {
    final m = _match!;
    final inn = _currentInnings;
    final maxBalls = m.oversLimit * 6;

    final allOut = inn.wickets >= 10; // 10 wickets down
    final oversDone = inn.legalBalls >= maxBalls;

    if (m.isSecondInnings) {
      // chasing logic: stop when target reached
      final target = m.target!;
      if (inn.runs >= target) {
        // innings (and match) over -> declare winner
        _declareWinnerOnChase();
        return;
      }
    }

    if (allOut || oversDone) {
      if (!m.isSecondInnings) {
        // start second innings
        m.inningsNumber = InningsNumber.second;
        m.innings2 = Innings(
          batting: m.innings1.bowling,
          bowling: m.innings1.batting,
        );
      } else {
        // match over -> decide winner based on runs
        _declareWinnerAfterSecondInnings();
      }
    }
  }

  // Called when a non-legal delivery (wide/no-ball) may have finished a chase
  void _maybeFinishOnChase() {
    if (_match == null) return;
    final m = _match!;
    if (!m.isSecondInnings) return;
    final inn = m.innings2!;
    final target = m.target!;
    if (inn.runs >= target) {
      _declareWinnerOnChase();
    }
  }

  void _declareWinnerOnChase() {
    final m = _match!;
    final inn = m.innings2!;
    final chasingTeamName = inn.batting.name;
    final wicketsLost = inn.wickets;
    final wicketsRemaining = 10 - wicketsLost;
    final plural = wicketsRemaining == 1 ? 'wicket' : 'wickets';
    _matchResult = '$chasingTeamName won by $wicketsRemaining $plural';
    _persistResult();
    notifyListeners();
  }

  void _declareWinnerAfterSecondInnings() {
    final m = _match!;
    final inn = m.innings2!;
    if (inn.runs == m.innings1.runs) {
      _matchResult = 'Match tied';
    } else if (inn.runs > m.innings1.runs) {
      // chasing team actually exceeded (edge), declare chase winner
      final wicketsRemaining = 10 - inn.wickets;
      final plural = wicketsRemaining == 1 ? 'wicket' : 'wickets';
      _matchResult = '${inn.batting.name} won by $wicketsRemaining $plural';
    } else {
      final runsMargin = m.innings1.runs - inn.runs;
      _matchResult = '${m.innings1.batting.name} won by $runsMargin runs';
    }
    _persistResult();
    notifyListeners();
  }

  // Persistence
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_match?.toJson()));
    await prefs.setString(_storageResultKey, jsonEncode(_matchResult));
  }

  Future<void> _persistResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageResultKey, jsonEncode(_matchResult));
  }

  Future<void> loadFromStorage() async {
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_storageKey);
    final r = prefs.getString(_storageResultKey);
    if (s != null) {
      try {
        final json = jsonDecode(s) as Map<String, dynamic>;
        _match = MatchModel.fromJson(json);
      } catch (_) {}
    }
    if (r != null) {
      try {
        final decoded = jsonDecode(r);
        _matchResult = decoded == null ? null : decoded.toString();
      } catch (_) {
        _matchResult = null;
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> reset() async {
    _pushHistory('reset');
    _match = null;
    _matchResult = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_storageResultKey);
    notifyListeners();
  }
}

// ============================= UI =============================

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _oversCtrl = TextEditingController(text: '20');
  Format _format = Format.t20;
  final List<TextEditingController> _teamAPlayers = List.generate(
    11,
    (i) => TextEditingController(text: 'A${i + 1}'),
  );
  final List<TextEditingController> _teamBPlayers = List.generate(
    11,
    (i) => TextEditingController(text: 'B${i + 1}'),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";

        final mc = context.watch<MatchController>();

        return Scaffold(
          backgroundColor: isDark
              ? Reusable.getDarkModeBlack()
              : Reusable.getWhite(),
          appBar: AppBar(
            title: Text(
              'Cricket Scoreboard — Setup',
              style: TextStyle(
                color: isDark
                    ? Reusable.getDarkModeBlack()
                    : Reusable.getWhite(),
              ),
            ),
            backgroundColor: isDark
                ? Reusable.getLightGreen()
                : Reusable.getGreen(),
          ),
          body: mc.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth > 800;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: isWide ? 360 : double.infinity,
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                    cursorColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    decoration: InputDecoration(
                                      // hintText: "Search by Name",
                                      labelText: 'Team A Name',
                                      labelStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(), // background color
                                      // 🔍 Search icon
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        size: Reusable.getDeviceWidth(
                                          context,
                                          W: 30,
                                        ),
                                      ),

                                      // Borders
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getLightGrey(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.orange,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.purple,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    controller: _teamAController,
                                    // decoration: const InputDecoration(

                                    //   border: OutlineInputBorder(),
                                    // ),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? 'Enter team name'
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? 360 : double.infinity,
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                    cursorColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    decoration: InputDecoration(
                                      // hintText: "Search by Name",
                                      labelText: 'Team B Name',
                                      labelStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(), // background color
                                      // 🔍 Search icon
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        size: Reusable.getDeviceWidth(
                                          context,
                                          W: 30,
                                        ),
                                      ),

                                      // Borders
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getLightGrey(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.orange,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.purple,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    controller: _teamBController,
                                    // decoration: const InputDecoration(
                                    //   border: OutlineInputBorder(),
                                    // ),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? 'Enter team name'
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? 200 : double.infinity,
                                  child: DropdownButtonFormField<Format>(
                                    iconEnabledColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    style: TextStyle(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                    // cursorColor: isDark
                                    // ? Reusable.getLightGreen()
                                    // : Reusable.getGreen(),
                                    decoration: InputDecoration(
                                      // hintText: "Search by Name",
                                      labelText: 'Format',
                                      labelStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(), // background color
                                      // 🔍 Search icon
                                      // suffixIcon: Icon(
                                      //   Icons.search,
                                      //   color: isDark
                                      //       ? Reusable.getLightGreen()
                                      //       : Reusable.getGreen(),
                                      //   size: Reusable.getDeviceWidth(
                                      //     context,
                                      //     W: 30,
                                      //   ),
                                      // ),

                                      // Borders
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getLightGrey(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.orange,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.purple,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    value: _format,
                                    dropdownColor: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                    items: [
                                      DropdownMenuItem(
                                        value: Format.t20,
                                        child: Text(
                                          'T20',
                                          style: TextStyle(
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getGreen(),
                                          ),
                                        ),
                                      ),

                                      const DropdownMenuItem(
                                        value: Format.odi,
                                        child: Text('ODI'),
                                      ),
                                    ],
                                    onChanged: (v) => setState(
                                      () => _format = v ?? Format.t20,
                                    ),
                                    // decoration: const InputDecoration(

                                    //   border: OutlineInputBorder(),
                                    // ),
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? 160 : double.infinity,
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                    cursorColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    decoration: InputDecoration(
                                      // hintText: "Search by Name",
                                      labelText: 'Overs Limit',
                                      labelStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(), // background color
                                      // 🔍 Search icon
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        size: Reusable.getDeviceWidth(
                                          context,
                                          W: 30,
                                        ),
                                      ),

                                      // Borders
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getLightGrey(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.orange,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.purple,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    controller: _oversCtrl,
                                    // decoration: const InputDecoration(

                                    //   border: OutlineInputBorder(),
                                    // ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final o = int.tryParse(v ?? '');
                                      if (o == null || o <= 0)
                                        return 'Enter overs';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                _playersPanel(
                                  'Team A Players',
                                  _teamAPlayers,
                                  isDark,
                                ),
                                _playersPanel(
                                  'Team B Players',
                                  _teamBPlayers,
                                  isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(), // button color
                                    foregroundColor: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(), // text color
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final overs =
                                          int.tryParse(_oversCtrl.text) ?? 0;
                                      if (overs <= 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Overs must be greater than 0',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      try {
                                        context
                                            .read<MatchController>()
                                            .configure(
                                              teamAName: _teamAController.text
                                                  .trim(),
                                              teamBName: _teamBController.text
                                                  .trim(),
                                              teamAPlayers: _teamAPlayers
                                                  .map((e) => e.text.trim())
                                                  .toList(),
                                              teamBPlayers: _teamBPlayers
                                                  .map((e) => e.text.trim())
                                                  .toList(),
                                              format: _format,
                                              oversLimit: overs,
                                            );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Invalid setup: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Start Match',
                                    style: TextStyle(
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  style: FilledButton.styleFrom(
                                    foregroundColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(), // button color
                                    backgroundColor: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(), // text color
                                    side: BorderSide(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(), // your border color
                                      width: 1, // optional: border width
                                    ),
                                  ),
                                  onPressed: () => context
                                      .read<MatchController>()
                                      .swapFirstBatting(),
                                  child: const Text('Swap First Batting Team'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _playersPanel(
    String title,
    List<TextEditingController> ctrls,
    bool isDark,
  ) {
    return SizedBox(
      width: 420,
      child: Card(
        color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < ctrls.length; i++)
                    SizedBox(
                      width: 120,
                      child: TextField(
                        style: TextStyle(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                        cursorColor: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                        decoration: InputDecoration(
                          // hintText: "Search by Name",
                          labelText: '${i + 1}',
                          labelStyle: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getDarkGrey(),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Reusable.getDarkModeBlack()
                              : Reusable.getWhite(), // background color
                          // 🔍 Search icon
                          // suffixIcon: Icon(
                          // Icons.search,
                          // color: isDark
                          // ? Reusable.getLightGreen()
                          // : Reusable.getGreen(),
                          // size: Reusable.getDeviceWidth(
                          // context,
                          // W: 30,
                          // ),
                          // ),

                          // Borders
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getLightGrey(),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.purple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: ctrls[i],
                        // decoration: InputDecoration(
                        //   labelText: '${i + 1}',
                        //   border: const OutlineInputBorder(),
                        // ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        final mc = context.watch<MatchController>();
        final m = mc.match!;
        final inn = m.isSecondInnings ? m.innings2! : m.innings1;

        final target = m.isSecondInnings ? m.target : null;
        final rrr = (target != null)
            ? _requiredRunRate(
                target,
                inn.runs,
                m.oversLimit * 6 - inn.legalBalls,
              )
            : null;

        return Scaffold(
          backgroundColor: isDark
              ? Reusable.getDarkModeBlack()
              : Reusable.getWhite(),
          appBar: AppBar(
            title: Text(
              '${inn.batting.name} vs ${inn.bowling.name}',
              style: TextStyle(
                color: isDark
                    ? Reusable.getDarkModeBlack()
                    : Reusable.getWhite(),
              ),
            ),
            backgroundColor: isDark
                ? Reusable.getLightGreen()
                : Reusable.getGreen(),

            actions: [
              if (mc.canUndo)
                IconButton(
                  tooltip: 'Undo last ball',
                  onPressed: mc.undo,
                  icon: const Icon(Icons.undo),
                ),
              IconButton(
                tooltip: 'Reset match',
                onPressed: () => _confirmReset(context),
                icon: Icon(
                  Icons.restart_alt,
                  color: isDark
                      ? Reusable.getDarkModeBlack()
                      : Reusable.getWhite(),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return MatchSummaryWidget();
                      },
                    ),
                  );
                },
                icon: Icon(
                  Icons.list_alt,
                  color: isDark
                      ? Reusable.getDarkModeBlack()
                      : Reusable.getWhite(),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth > 900;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Show result banner when match over
                    Builder(
                      builder: (ctx) {
                        final result = context
                            .watch<MatchController>()
                            .matchResult;
                        if (result != null) {
                          return Card(
                            color: Colors.green.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      result,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 12),
                    _headlineCard(context, isDark),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: wide ? 480 : double.infinity,
                          child: _battingCard(context, isDark),
                        ),
                        SizedBox(
                          width: wide ? 360 : double.infinity,
                          child: _bowlingCard(context, isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _controlsCard(context, isDark),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _headlineCard(BuildContext context, bool isDark) {
    final mc = context.watch<MatchController>();
    final m = mc.match!;
    final inn = m.isSecondInnings ? m.innings2! : m.innings1;

    final target = m.isSecondInnings ? m.target : null;
    final rrr = (target != null)
        ? _requiredRunRate(target, inn.runs, m.oversLimit * 6 - inn.legalBalls)
        : null;

    return Card(
      color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${inn.batting.name}: ${inn.runs}/${inn.wickets}  (${inn.oversString} ov)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                    ),
                  ),
                ),
                if (inn.freeHitNextLegal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'FREE HIT',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'CRR: ${inn.crr.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
                if (target != null)
                  Text(
                    'Target: $target',
                    style: TextStyle(
                      color: isDark
                          ? Reusable.getLightGrey()
                          : Reusable.getBlack(),
                    ),
                  ),
                if (rrr != null)
                  Text(
                    'RRR: ${rrr.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDark
                          ? Reusable.getLightGrey()
                          : Reusable.getBlack(),
                    ),
                  ),
                Text(
                  'Extras: ${inn.extras.total} (Wd ${inn.extras.wides}, NB ${inn.extras.noBalls}, B ${inn.extras.byes}, LB ${inn.extras.legByes})',

                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ],
            ),
            if (target != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Need ${target - inn.runs} from ${(m.oversLimit * 6 - inn.legalBalls)} balls',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _battingCard(BuildContext context, bool isDark) {
    final mc = context.watch<MatchController>();
    final m = mc.match!;
    final inn = m.isSecondInnings ? m.innings2! : m.innings1;
    final striker = inn.striker;
    final nonStriker = inn.nonStriker;

    DataRow row(Player p, {bool star = false}) => DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              if (star)
                Icon(
                  Icons.sports_cricket,
                  size: 16,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              Text(
                p.name,
                style: TextStyle(
                  color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            '${p.runs}',
            style: TextStyle(
              color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
            ),
          ),
        ),
        DataCell(
          Text(
            '${p.ballsFaced}',
            style: TextStyle(
              color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
            ),
          ),
        ),
        DataCell(
          Text(
            '${p.fours}',
            style: TextStyle(
              color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
            ),
          ),
        ),
        DataCell(
          Text(
            '${p.sixes}',
            style: TextStyle(
              color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
            ),
          ),
        ),
        DataCell(
          Text(
            p.out ? (p.dismissalNote) : 'not out',
            style: TextStyle(
              color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
            ),
          ),
        ),
      ],
    );

    return Card(
      color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batting',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Batsman',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'R',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'B',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '4s',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '6s',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                ],
                rows: [row(striker, star: true), row(nonStriker)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bowlingCard(BuildContext context, bool isDark) {
    final mc = context.watch<MatchController>();
    final m = mc.match!;
    final inn = m.isSecondInnings ? m.innings2! : m.innings1;

    final currentBowlerIndex = inn.currentBowlerIndex;

    return Card(
      color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Bowling',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                  ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  iconEnabledColor: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                  dropdownColor: isDark
                      ? Reusable.getDarkModeBlack()
                      : Reusable.getWhite(),
                  value: currentBowlerIndex,
                  hint: Text(
                    'Select Bowler',
                    style: TextStyle(
                      color: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                    ),
                  ),
                  items: [
                    for (int i = 0; i < inn.bowling.players.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          inn.bowling.players[i].name,
                          style: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                          ),
                        ),
                      ),
                  ],
                  onChanged: (v) =>
                      context.read<MatchController>().selectBowler(v ?? 0),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Bowler',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'O',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'R',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'W',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Econ',
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                  ),
                ],
                rows: [
                  for (final entry in inn.bowlers.entries)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getBlack(),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (entry.value.overs).toStringAsFixed(1),
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getBlack(),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${entry.value.runsConceded}',
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getBlack(),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${entry.value.wickets}',
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getBlack(),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            entry.value.economy.toStringAsFixed(2),
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getBlack(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (inn.ballsIntoOver == 0 && inn.oversCompleted > 0)
              Text(
                'New over: choose a different bowler than last over.',
                style: TextStyle(
                  color: isDark ? Reusable.getLightGrey() : Reusable.getBlack(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _controlsCard(BuildContext context, bool isDark) {
    final mc = context.watch<MatchController>();
    final m = mc.match!;
    final inn = m.isSecondInnings ? m.innings2! : m.innings1;

    final buttons = <Widget>[
      _pill('• 0', () => mc.scoreRuns(0), isDark: isDark),
      _pill('1', () => mc.scoreRuns(1), isDark: isDark),
      _pill('2', () => mc.scoreRuns(2), isDark: isDark),
      _pill('3', () => mc.scoreRuns(3), isDark: isDark),
      _pill('4', () => mc.scoreRuns(4), isDark: isDark),
      _pill('6', () => mc.scoreRuns(6), isDark: isDark),
      // const SizedBox(width: 16),
      _pill('Bye 1', () => mc.bye(1), isDark: isDark),
      _pill('Bye 2', () => mc.bye(2), isDark: isDark),
      _pill('LB 1', () => mc.legBye(1), isDark: isDark),
      _pill('LB 2', () => mc.legBye(2), isDark: isDark),
      // const SizedBox(width: 16),
      _pill('Wide +1', () => mc.wide(1), isDark: isDark),
      _pill('Wide +2', () => mc.wide(2), isDark: isDark),
      _pill('No Ball +1', () => mc.noBall(), isDark: isDark),
      _pill('NB +1 & Bat+1', () => mc.noBall(runsOffBat: 1), isDark: isDark),
      _pill('NB +1 & Bat+2', () => mc.noBall(runsOffBat: 2), isDark: isDark),
      _pill('NB +1 & 4', () => mc.noBall(runsOffBat: 4), isDark: isDark),
      _pill('NB +1 & 6', () => mc.noBall(runsOffBat: 6), isDark: isDark),
      // const SizedBox(width: 16),
      _pill(
        'Wkt (RunOut/HitWkt)',
        () => mc.wicket(dismissal: Dismissal.runOutHitWicket),
        isDark: isDark,
      ),
      _pill(
        'Wkt (Bowled/Caught/LBW)',
        () => mc.wicket(dismissal: Dismissal.bowledCaughtLBW),
        isDark: isDark,
      ),
    ];

    return Card(
      color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ball Controls',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: buttons),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    inn.freeHitNextLegal
                        ? 'Next LEGAL ball is a FREE HIT. Only Run Out / Hit Wicket can dismiss.'
                        : 'Tip: Wides & No-balls do not count as legal deliveries.',
                    style: TextStyle(
                      color: isDark
                          ? Reusable.getLightGrey()
                          : Reusable.getBlack(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, VoidCallback onTap, {required bool isDark}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        foregroundColor: isDark
            ? Reusable.getDarkModeBlack()
            : Reusable.getWhite(),
        backgroundColor: isDark
            ? Reusable.getLightGreen()
            : Reusable.getGreen(),
      ),
      child: Text(text),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset match?'),
        content: const Text('This will clear all saved data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<MatchController>().reset();
    }
  }
}

// ============================= UTIL =============================

double _requiredRunRate(int target, int current, int ballsLeft) {
  final runsNeeded = (target - current).clamp(0, 1000000);
  if (ballsLeft <= 0) return double.infinity;
  return runsNeeded / (ballsLeft / 6);
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// ==================== WIDGET TO SHOW SUMMARY TABLES ====================
class MatchSummaryWidget extends StatelessWidget {
  const MatchSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        final mc = context.watch<MatchController>();
        final match = mc.match;
        if (match == null)
          return const Center(child: Text('No match configured'));

        final innings1 = match.innings1;
        final innings2 = match.innings2;

        return Scaffold(
          backgroundColor: isDark
              ? Reusable.getDarkModeBlack()
              : Reusable.getWhite(),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isDark
                    ? Reusable.getDarkModeBlack()
                    : Reusable.getWhite(),
              ),
            ),
            title: Text(
              "Team Stats",
              style: TextStyle(
                color: isDark
                    ? Reusable.getDarkModeBlack()
                    : Reusable.getWhite(),
              ),
            ),
            backgroundColor: isDark
                ? Reusable.getLightGreen()
                : Reusable.getGreen(),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _teamStatsCard(
                  context,
                  match.teamA,
                  innings1,
                  'Team A',
                  isDark,
                ),
                const SizedBox(height: 20),
                if (innings2 != null)
                  _teamStatsCard(
                    context,
                    match.teamB,
                    innings2,
                    'Team B',
                    isDark,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _teamStatsCard(
    BuildContext context,
    Team team,
    Innings inn,
    String title,
    bool isDark,
  ) {
    return Card(
      color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),

      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon for detailed stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.bar_chart,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatsDetailScreen(match: inn),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Batsmen Table
            Text(
              'Batting',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
              ),
            ),
            const SizedBox(height: 6),
            _batsmenTable(inn, isDark),
            const SizedBox(height: 12),
            // Bowlers Table
            Text(
              'Bowling',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
              ),
            ),
            const SizedBox(height: 6),
            _bowlersTable(inn, isDark),
          ],
        ),
      ),
    );
  }

  Widget _batsmenTable(Innings inn, bool isDark) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(3), // Name
        1: FlexColumnWidth(1), // Runs
        2: FlexColumnWidth(1), // Balls
        3: FlexColumnWidth(1), // 4s
        4: FlexColumnWidth(1), // 6s
        5: FlexColumnWidth(1), // SR
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? Reusable.getDarkModeBlack() : Reusable.getBlack(),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Batsman',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'R',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'B',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                '4s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                '6s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'SR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
          ],
        ),
        ...inn.batting.players.map((p) {
          final sr = p.ballsFaced == 0
              ? '-'
              : ((p.runs / p.ballsFaced) * 100).toStringAsFixed(1);
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  p.name,
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  p.ballsFaced == 0 ? '-' : '${p.runs}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  p.ballsFaced == 0 ? '-' : '${p.ballsFaced}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  p.ballsFaced == 0 ? '-' : '${p.fours}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  p.ballsFaced == 0 ? '-' : '${p.sixes}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  p.ballsFaced == 0 ? '-' : sr,
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _bowlersTable(Innings inn, bool isDark) {
    final bowlers = inn.bowling.players
        .map((p) => inn.bowlers[p.name])
        .toList();
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(3), // Name
        1: FlexColumnWidth(1), // Overs
        2: FlexColumnWidth(1), // Runs
        3: FlexColumnWidth(1), // Wickets
        4: FlexColumnWidth(1), // Economy
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? Reusable.getDarkModeBlack() : Reusable.getBlack(),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Bowler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'O',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'R',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'W',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'Econ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
              ),
            ),
          ],
        ),
        ...inn.bowling.players.map((p) {
          final stat = inn.bowlers[p.name];
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(4), child: Text(p.name,style: TextStyle(color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),),)),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  stat == null ? '-' : '${stat.overs.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  stat == null ? '-' : '${stat.runsConceded}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  stat == null ? '-' : '${stat.wickets}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  stat == null ? '-' : '${stat.economy.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: isDark
                        ? Reusable.getLightGrey()
                        : Reusable.getBlack(),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}

// ===================== DETAILED STATS SCREEN =====================
class StatsDetailScreen extends StatelessWidget {
  final Innings match;

  const StatsDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          appBar: AppBar(title: const Text('Detailed Stats')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Batting',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                MatchSummaryWidget()._batsmenTable(match, isDark),
                const SizedBox(height: 12),
                const Text(
                  'Bowling',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                MatchSummaryWidget()._bowlersTable(match, isDark),
              ],
            ),
          ),
        );
      },
    );
  }
}
