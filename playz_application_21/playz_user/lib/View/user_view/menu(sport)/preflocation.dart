import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/play(sport)/mappicker.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:http/http.dart' as http;

ValueNotifier<String?> selectedLocationNotifier = ValueNotifier(null);

class PrefLocation extends StatefulWidget {
  final VoidCallback? onReload;

  const PrefLocation({super.key, this.onReload});
  // const PrefLocation({super.key});

  @override
  State<PrefLocation> createState() => _PrefLocationState();
}

class _PrefLocationState extends State<PrefLocation> {
  LatLng? selectedLatLng;
  String? selectedAddress;
  String? selectedCity;
  List<Map<String, dynamic>> localityList = [];

  /// Fetch city/district/sublocality from latitude & longitude
  Future<String?> getCityFromLatLng(double lat, double lng) async {
    final apiKey =
        "AIzaSyC_7gB2nUKVkI4CQpjkWJrxCy2hTSGILKE"; // replace with your API key
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        final results = data["results"] as List;

        for (var result in results) {
          for (var component in result["address_components"]) {
            List types = component["types"];

            if (types.contains("locality")) {
              return component["long_name"]; // City
            } else if (types.contains("administrative_area_level_2")) {
              return component["long_name"]; // District (fallback)
            } else if (types.contains("sublocality")) {
              return component["long_name"]; // Area (last fallback)
            }
          }
        }
      } else {
        log("Geocoding failed: ${data["status"]}");
      }
    } else {
      log("HTTP error: ${response.statusCode}");
    }

    return null; // If no city found
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              /// Green background with top bar
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
                        /// Back button
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
                        const SizedBox(width: 5),

                        /// Page title
                        ValueListenableBuilder<String>(
                          valueListenable: appLanguageNotifier,
                          builder: (context, lang, _) {
                            return FutureBuilder<String>(
                              future: getTranslatedText("Locations", lang),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "...",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    "Error",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data ?? "",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// White rounded container at bottom
              Positioned(
                top: (MediaQuery.of(context).size.height) * 0.097192,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Add button (opens map picker)
                      Padding(
                        padding: EdgeInsets.only(
                          right: Reusable.getDeviceWidth(context, W: 15),
                          top: Reusable.getDeviceHeight(context, H: 15),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPickerPage(
                                    onLocationPicked: (LatLng pos, String address) async {
                                      log("Picked address: $address");

                                      final city = await getCityFromLatLng(
                                        pos.latitude,
                                        pos.longitude,
                                      );

                                      log("Detected city: $city");
                                      if (city != null) {
                                        localityList.add({
                                          "city": city,
                                          "latlang": pos,
                                        });
                                        selectedLocationNotifier.value = city;

                                        await Appsharedpreferences.saveSelectedCity(
                                          city,
                                          pos,
                                        );
                                      } else {
                                        log(
                                          "❌ Could not determine city. Geocoding failed.",
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Failed to fetch location name.",
                                            ),
                                          ),
                                        );
                                      }

                                      log("List: ${localityList}");
                                      // await HomePage()._loadSelectedLocation();
                                      log(
                                        "${await Appsharedpreferences().loadSelectedCity()}",
                                      );
                                      log(
                                        "${await Appsharedpreferences().loadSelectedLatLng()}",
                                      );

                                      setState(() {
                                        selectedLatLng = pos;
                                        selectedAddress = address;
                                        selectedCity = city;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              size: Reusable.getDeviceWidth(context, W: 40),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),

                      //  Show selected city (if available)

                      // Padding(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: Reusable.getDeviceWidth(context, W: 30),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         selectedCity!,
                      //         style: TextStyle(
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.w500,
                      //           color: Reusable.getGreen(),
                      //         ),
                      //       ),
                      //       Icon(
                      //         Icons.close,
                      //         color: Reusable.getGreen(),
                      //         size: Reusable.getDeviceWidth(context, W: 30),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: localityList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Reusable.getDeviceWidth(
                                  context,
                                  W: 30,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite(),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await Appsharedpreferences.saveSelectedCity(
                                          localityList[index]['city'],
                                          localityList[index]['latlang'],
                                        );
                                        widget.onReload?.call();
                                        Navigator.of(context).pop();
                                        // _loadSelectedLocation();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                        child: ValueListenableBuilder<String>(
                                          valueListenable: appLanguageNotifier,
                                          builder: (context, lang, _) {
                                            return FutureBuilder<String>(
                                              future: getTranslatedText(
                                                localityList[index]['city'],
                                                lang,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Text(
                                                    "...",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen(),
                                                    ),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                    "Error",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen(),
                                                    ),
                                                  );
                                                } else {
                                                  return Text(
                                                    snapshot.data ?? "",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen(),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        localityList.removeAt(index);
                                        if (await Appsharedpreferences()
                                                .loadSelectedCity() ==
                                            localityList[index]['city']) {
                                          Appsharedpreferences.saveSelectedCity(
                                            null,
                                            null,
                                          );
                                          selectedLocationNotifier.value = null;
                                        }
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        size: Reusable.getDeviceWidth(
                                          context,
                                          W: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
