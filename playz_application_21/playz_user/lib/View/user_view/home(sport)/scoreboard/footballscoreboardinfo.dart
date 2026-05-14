import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/home(sport)/scoreboard/footballscoreboard.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

class FootballScoreboardInfo extends StatefulWidget {
  const FootballScoreboardInfo({super.key});

  @override
  State<FootballScoreboardInfo> createState() => _FootballScoreboardInfoState();
}

// 🔹 Dummy list of group members (image, name, role)
List<Map<String, dynamic>> FootballScoreboardInfoCardList = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
];

class _FootballScoreboardInfoState extends State<FootballScoreboardInfo> {
  List<List<String>> pageItems = [
    ["Item 1", "Item 2","Item 3"],
    ["Item A", "Item B"],
    ["One", "Two"],
  ];
  String? selectedOver;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";

        return Scaffold(
          body: Stack(
            // Stack is used to overlap top header and white sheet
            children: [
              // 🔹 Green header background
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),

                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      children: [
                        // 🔙 Back button
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: Reusable.getDeviceWidth(context, W: 25),
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                          ),
                        ),
                        SizedBox(width: 5),
                        // 🔹 Title text
                        Text(
                          "Football Scoreboard",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 White rounded bottom sheet (Main content area)
              Positioned(
                top:
                    (MediaQuery.of(context).size.height) *
                    0.097192, // pushes down from top
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      Container(
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Reusable.getDarkModeGrey()
                              : Reusable.getWhite(),
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: Reusable.getDeviceHeight(context, H: 10),
                                left: Reusable.getDeviceWidth(context, W: 15),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Team Details",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getBlack(),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: Reusable.getDeviceHeight(context, H: 10),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                bottom: Reusable.getDeviceHeight(
                                  context,
                                  H: 15,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 60,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 358,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 30),
                                      ),
                                    ),
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
                                        hintText: "Search by Name",
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.purple,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 10,
                                    ),
                                  ),

                                  Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 60,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 358,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 30),
                                      ),
                                    ),
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
                                        hintText: "Search by Name",
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.purple,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      Container(
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Reusable.getDarkModeGrey()
                              : Reusable.getWhite(),
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: Reusable.getDeviceHeight(context, H: 10),
                                left: Reusable.getDeviceWidth(context, W: 15),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Overs & Team Size",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getBlack(),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: Reusable.getDeviceHeight(context, H: 10),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    selectedOver = "30 MIN";
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 85,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? (selectedOver == "30 MIN")
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkModeBlack()
                                          : (selectedOver == "30 MIN")
                                          ? Reusable.getGreen()
                                          : Reusable.getWhite(),

                                      border: Border.all(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "30 MIN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? (selectedOver == "30 MIN")
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getLightGreen()
                                              : (selectedOver == "30 MIN")
                                              ? Reusable.getWhite()
                                              : Reusable.getGreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: Reusable.getDeviceWidth(
                                    context,
                                    W: 10,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    selectedOver = "60 MIN";
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 85,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? (selectedOver == "60 MIN")
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkModeBlack()
                                          : (selectedOver == "60 MIN")
                                          ? Reusable.getGreen()
                                          : Reusable.getWhite(),

                                      border: Border.all(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "60 MIN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? (selectedOver == "60 MIN")
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getLightGreen()
                                              : (selectedOver == "60 MIN")
                                              ? Reusable.getWhite()
                                              : Reusable.getGreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: Reusable.getDeviceWidth(
                                    context,
                                    W: 10,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    selectedOver = "90 MIN";
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 85,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? (selectedOver == "90 MIN")
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkModeBlack()
                                          : (selectedOver == "90 MIN")
                                          ? Reusable.getGreen()
                                          : Reusable.getWhite(),

                                      border: Border.all(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "90 MIN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? (selectedOver == "90 MIN")
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getLightGreen()
                                              : (selectedOver == "90 MIN")
                                              ? Reusable.getWhite()
                                              : Reusable.getGreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: Reusable.getDeviceWidth(
                                    context,
                                    W: 10,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    selectedOver = "custom";
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 85,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? (selectedOver == "custom")
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkModeBlack()
                                          : (selectedOver == "custom")
                                          ? Reusable.getGreen()
                                          : Reusable.getWhite(),

                                      border: Border.all(
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Custom",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? (selectedOver == "custom")
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getLightGreen()
                                              : (selectedOver == "custom")
                                              ? Reusable.getWhite()
                                              : Reusable.getGreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Reusable.getDeviceHeight(context, H: 20),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                bottom: Reusable.getDeviceHeight(
                                  context,
                                  H: 15,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 5,
                                    ),
                                  ),
                                  Text(
                                    "10 Players",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? Reusable.getLightGrey()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 5,
                                    ),
                                  ),

                                  Icon(
                                    Icons.remove_circle_outline,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ],
                              ),
                            ),

                            (selectedOver == "custom")
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      bottom: Reusable.getDeviceHeight(
                                        context,
                                        H: 10,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                        SizedBox(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 5,
                                          ),
                                        ),
                                        Text(
                                          "30 MIN",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: isDark
                                                ? Reusable.getLightGrey()
                                                : Reusable.getDarkGrey(),
                                          ),
                                        ),
                                        SizedBox(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 5,
                                          ),
                                        ),

                                        Icon(
                                          Icons.remove_circle_outline,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),

                      Expanded(
                        child: PageView.builder(
                          itemCount: pageItems.length,
                          itemBuilder: (context, pageIndex) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // TextField on top
                                  TextField(
                                    style: TextStyle(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                    cursorColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    decoration: InputDecoration(
                                      hintText: "Search by Name",
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
                                  ),
                                   SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),

                                  // List of containers with close icon
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: pageItems[pageIndex].length,
                                      itemBuilder: (context, itemIndex) {
                                        return Column(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
color: isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),
border: Border.all(color: isDark?Reusable.getLightGreen():Reusable.getGreen(),
),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    pageItems[pageIndex][itemIndex],
                                                    style:  TextStyle(
                                                      fontSize: 16,
                                                      color: isDark?Reusable.getLightGreen():Reusable.getDarkGrey(),

                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        pageItems[pageIndex]
                                                            .removeAt(
                                                              itemIndex,
                                                            );
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Spacer(),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Reusable.getDeviceHeight(context, H: 40),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return FootballScoreboard();
                                },
                              ),
                            );
                          },
                          child: Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "START GAME",
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
