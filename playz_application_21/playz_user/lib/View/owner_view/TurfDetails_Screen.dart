import 'package:flutter/material.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_Turf_Services.dart';
import 'package:playz_user/View/owner_view/Owner_Map_Picker.dart';
import 'package:playz_user/View/owner_view/TurfTimeslot_Screen.dart';
import 'package:playz_user/View/owner_view/Welcome_Screen.dart';
import 'package:playz_user/View/user_view/play(sport)/mappicker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';

class ownerTurfDetailScreen extends StatefulWidget {
  final String? email_ID;
  final String? turfName;
  final Map<String,dynamic> fetchedData;
   bool doEdit = false;
   ownerTurfDetailScreen({required this.doEdit,required this.email_ID,required this.turfName,required this.fetchedData,super.key});

  @override
  State<ownerTurfDetailScreen> createState() => _ownerTurfDetailScreenState();
}

class _ownerTurfDetailScreenState extends State<ownerTurfDetailScreen> {
     bool doEdit = false;

  //Sports And Amenities
  TextEditingController ownerSports = TextEditingController();
  TextEditingController ownerLocation = TextEditingController();
  List<String> sports = [];
  List<String> amenities = [
    "Floodlights",
    "Changing Rooms",
    "Washrooms",
    "Drinking Water",
    "First Aid",
    "Parking",
    "Food",
    "CCTV",
    "Security Staff",
    "Umpire/Referee",
  ];

  Map<String, bool> amenitySelected = {};
  //Step Progresser
  int currentStep = 2;

  Widget _buildStep(int step) {
    bool isActive = step == currentStep;
    bool isCompleted = step < currentStep;

    return CircleAvatar(
      radius: 20,
      backgroundColor:
          isActive
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
  //Controller Instance
  final TurfService _turfService = TurfService();
Map<String,dynamic> fetchedData = {};
  //Amesnities
  @override
  void initState() { 
    super.initState();
    doEdit = widget.doEdit;
if (widget.doEdit) {
  fetchedData = widget.fetchedData;
      amenitySelected = {
      for (var amenity in amenities)
        amenity: false, // just for demo, some are checked

      for (var amenity in fetchedData['amenities'])
        amenity: true,
    };

     sports = (fetchedData['sports'] as List<dynamic>).cast<String>().toList();

        ownerLocation.text = fetchedData['location']['address'];
        
        selectedAddress = fetchedData['location']['address'];
        selectedLatLng = LatLng(fetchedData['location']['latitude'] ?? 0, fetchedData['location']['longitude']?? 0);
}
  }

  LatLng? selectedLatLng;
  String? selectedAddress;

  @override
  Widget build(BuildContext context) {
    String email = widget.email_ID??"";
    String turfName = widget.turfName??"";
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 15),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Row(
                        children: [
                           IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Color.fromRGBO(13, 71, 161, 1),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Turf Details",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(13, 71, 161, 1),
                          ),
                        ),
                        ],
                       ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ownerWelcomeAddTurf();
                                },
                              ),
                              (route) => false,
                            );
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
                      "Sports Available",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 388,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(237, 237, 237, 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: ownerSports,
                          decoration: InputDecoration(
                            suffix: IconButton(
                              onPressed: () {
                                sports.add(ownerSports.text);
                                setState(() {});
                              },
                              icon: Icon(Icons.search),
                            ),
                            hintText: "Search For Sports",
                            fillColor: Color.fromRGBO(237, 237, 237, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding:EdgeInsets.all(20)
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children:
                          sports
                              .map(
                                (sport) => Chip(
                                  label: Text(
                                    sport,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  labelPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  deleteIcon: Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      sports.remove(sport);
                                    });
                                  },
                                  shape: StadiumBorder(),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Select Amenities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          amenities.map((amenity) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(13, 71, 161, 1),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: amenitySelected[amenity] ?? false,
                                    onChanged: (value) {
                                      setState(() {
                                        amenitySelected[amenity] =
                                            value ?? false;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    side: BorderSide(
                                      color: Color.fromRGBO(13, 71, 161, 1),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Text(
                                    amenity,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(13, 71, 161, 1),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Turf Location",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 388,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(237, 237, 237, 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OwnerMapPickerPage(
                                  onLocationPicked: (LatLng pos, String address) async {
                                    setState(() {
                                      selectedLatLng = pos;
                                      selectedAddress = address;
                                      ownerLocation.text = address;
                                    });
                                    log("Selected Address: $address");
                                    log("Selected LatLng: $pos");
                                  },
                                ),
                              ),
                            );
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: ownerLocation,
                              decoration: InputDecoration(
                                suffix: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.location_on),
                                ),
                                hintText: "Select Location",
                                fillColor: Color.fromRGBO(237, 237, 237, 1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 388,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async{
                          await _turfService.saveTurfDetails(context: context, sports: sports, amenities: amenitySelected.entries
                            .where((e) => e.value == true)
                            .map((e) => e.key)
                            .toList(), address: selectedAddress!, latitude:selectedLatLng!.latitude, longitude: selectedLatLng!.longitude, email_ID:email, turfName: turfName);
                         
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ownerTimeSlot(email_ID: email ,turfName: turfName , doEdit: doEdit, fetchedData: fetchedData );
                              },
                            ),
                          );
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
