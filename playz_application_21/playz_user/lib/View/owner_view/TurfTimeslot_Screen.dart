import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_Turf_TimeSlots.dart';
import 'package:playz_user/View/owner_view/RegisterSuccessful_Screen.dart';
import 'package:playz_user/View/owner_view/Welcome_Screen.dart';


class ownerTimeSlot extends StatefulWidget {
  final String? email_ID;
  final String? turfName;
  bool doEdit = false;
  final Map<String,dynamic> fetchedData;
   ownerTimeSlot({required this.doEdit,required this.fetchedData,required this.email_ID,required this.turfName,Key? key}) : super(key: key);

  @override
  State<ownerTimeSlot> createState() => _ownerTimeSlotState();
}

class _ownerTimeSlotState extends State<ownerTimeSlot> {
     Map<String,dynamic> fetchedData = {};

  // Existing step progress code
  int currentStep = 3;

  Widget _buildStep(int step) {
    bool isActive = step == currentStep;
    bool isComplete = step < currentStep;
    return CircleAvatar(
      radius: 20,
      backgroundColor:
          isActive
              ? Color(0xFF0D47A1)
              : (isComplete ? Colors.green : Colors.grey.shade300),
      child: Text(
        '$step',
        style: TextStyle(
          color: (isActive || isComplete) ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLine() =>
      SizedBox(width: 120, child: Divider(color: Colors.grey, thickness: 4));

  // --- New functional UI code begins ---
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  int selectedDayIndex = 0;

  TimeOfDay startTime = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 23, minute: 0);

  bool available24_7 = true;
  bool syncPrice = true;

  final picker = ImagePicker();
  File? idProof;

  // Half-hour slots from 5 AM to 11 PM
  final List<String> timeSlots = [
    "5:00 AM",
    "5:30 AM",
    "6:00 AM",
    "6:30 AM",
    "7:00 AM",
    "7:30 AM",
    "8:00 AM",
    "8:30 AM",
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
    "3:30 PM",
    "4:00 PM",
    "4:30 PM",
    "5:00 PM",
    "5:30 PM",
    "6:00 PM",
    "6:30 PM",
    "7:00 PM",
    "7:30 PM",
    "8:00 PM",
    "8:30 PM",
    "9:00 PM",
    "9:30 PM",
    "10:00 PM",
    "10:30 PM",
    "11:00 PM",
  ];

  Map<String, List<bool>> offHoursMap = {};
  Map<String, List<bool>> slotSelectedMap = {};
  Map<String, int> slotPrices = {};
  //method useful for firebase
  Map<String, List<Map<String, dynamic>>> getSelectedSlotsWithPrices() {
  Map<String, List<Map<String, dynamic>>> selectedData = {};
  for (var day in days) {
    var slotsForDay = <Map<String, dynamic>>[];
    for (int i = 0; i < slotSelectedMap[day]!.length; i++) {
      if (slotSelectedMap[day]![i]) {
        slotsForDay.add({
          'timeRange': slotRange(i),
          'price': slotPrices["$day-$i"] ?? 1000,
        });
      }
    }
    if (slotsForDay.isNotEmpty) {
      selectedData[day] = slotsForDay;
    }
  }
  return selectedData;
}
final List<XFile> _idImages = [];
 List<String> _fetchedImages = [];

bool doEdit = false;
  @override
  void initState() {
    super.initState();
    if (widget.doEdit) {
      doEdit = widget.doEdit;
      fetchedData = widget.fetchedData;
      upiIdOwner.text = fetchedData['upiId'] ?? "upi";
      _fetchedImages = (fetchedData['idProofUrl'] ?? [''] as List<dynamic>).cast<String>().toList();
    }
    for (var day in days) {
      offHoursMap[day] = List.generate(timeSlots.length, (_) => false);
      slotSelectedMap[day] = List.generate(timeSlots.length ~/ 2, (_) => false);
      for (int i = 0; i < timeSlots.length ~/ 2; i++) {
        slotPrices["$day-$i"] = 1000;
      }
    }
  }
  TextEditingController upiIdOwner=TextEditingController();

  int _slotTimeMinutes(String s) {
    final parts = s.split(' ');
    final timePart = parts[0].split(':');
    int hour = int.parse(timePart[0]);
    int min = int.parse(timePart[1]);
    bool isPM = parts[1].toLowerCase() == "pm";
    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    return hour * 60 + min;
  }

  Future<void> pickTime(bool isStart) async {
    TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (t != null) {
      setState(() {
        if (isStart)
          startTime = t;
        else
          endTime = t;
      });
    }
  }

  void toggleOffHour(int idx) {
    setState(() {
      final day = days[selectedDayIndex];
      offHoursMap[day]![idx] = !offHoursMap[day]![idx];
    });
  }

  void toggleSlotSelected(int idx) {
    setState(() {
      final day = days[selectedDayIndex];
      slotSelectedMap[day]![idx] = !slotSelectedMap[day]![idx];
    });
  }

  void updatePrice(int idx, String val) {
    int price = int.tryParse(val) ?? 1000;
    final day = days[selectedDayIndex];
    if (syncPrice) {
      for (int i = 0; i < slotSelectedMap[day]!.length; i++) {
        if (slotSelectedMap[day]![i]) slotPrices["$day-$i"] = price;
      }
    } else {
      slotPrices["$day-$idx"] = price;
    }
    setState(() {});
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? picked = await picker.pickMultiImage();
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _idImages.addAll(picked);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      doEdit ? _fetchedImages.removeAt(index):_idImages.removeAt(index);
    });
  }
  final TurfSlotService _turfSlotService = TurfSlotService();

  String slotRange(int idx) {
    if (idx * 2 + 2 >= timeSlots.length) return "";
    return "${timeSlots[idx * 2]} - ${timeSlots[idx * 2 + 2]}";
  }

  List<int> get validSlotIndices {
    // Only show grid slots between start and end time
    int start = startTime.hour * 60 + startTime.minute;
    int end = endTime.hour * 60 + endTime.minute;
    return List<int>.generate(timeSlots.length, (i) {
      int slotM = _slotTimeMinutes(timeSlots[i]);
      return (slotM >= start && slotM < end) ? i : -1;
    }).where((i) => i != -1).toList();
  }
  List<String> _downloadUrls = [];

  List<int> get validSlotPriceIndices {
    // Show only those between start/end AND not off
    int start = startTime.hour * 60 + startTime.minute;
    int end = endTime.hour * 60 + endTime.minute;
    final day = days[selectedDayIndex];
    return List<int>.generate(slotSelectedMap[day]!.length, (i) {
      // Both half-hour slots composing the range should be in allowed, AND both not off
      int idxA = i * 2;
      int idxB = idxA + 1;
      if (idxB + 1 >= timeSlots.length) return -1;
      int tA = _slotTimeMinutes(timeSlots[idxA]);
      int tB = _slotTimeMinutes(timeSlots[idxB]);
      int tC = _slotTimeMinutes(timeSlots[idxB + 1]);
      final isAin = (tA >= start && tB < end && tC <= end);
      final isAoff = offHoursMap[day]![idxA] || offHoursMap[day]![idxA + 1];
      return (isAin && !isAoff) ? i : -1;
    }).where((i) => i != -1).toList();
  }

  @override
  Widget build(BuildContext context) {
    String email = widget.email_ID??"";
    String turfName = widget.turfName??"";
    final currentDay = days[selectedDayIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header and Navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Turf Slots",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            color: Color.fromRGBO(13, 71, 161, 1),
                          ),
                        ),
                      ),
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
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStep(1),
                    _buildLine(),
                    _buildStep(2),
                    _buildLine(),
                    _buildStep(3),
                  ],
                ),
                SizedBox(height: 28),
                Text(
                  "Venue Timing",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 10),
                // Time selectors in scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 70,
                        width: 220,
                        child: _timeBox(
                          "Start Time",
                          startTime.format(context),
                          () {
                            pickTime(true);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        height: 70,
                        width: 220,
                        child: _timeBox(
                          "End Time",
                          endTime.format(context),
                          () {
                            pickTime(false);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Text("Available 24/7"),
                    Switch(
                      value: available24_7,
                      onChanged:
                          (val) => setState(() {
                            available24_7 = val;
                          }),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Text(
                  "Select Off-Hours",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 10),
                // Off-Hours grid (now filtered by time range)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: validSlotIndices.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (context, idx) {
                    int realIdx = validSlotIndices[idx];
                    bool selected = offHoursMap[currentDay]![realIdx];
                    return GestureDetector(
                      onTap: () {
                        toggleOffHour(realIdx);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? const Color.fromARGB(255, 126, 124, 124)
                                  : Colors.white,
                          border: Border.all(
                            color:
                                selected
                                    ? const Color.fromARGB(255, 147, 146, 146)
                                    : Colors.grey,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          timeSlots[realIdx],
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Text(
                  "Select Slot Prices",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 10),
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    itemBuilder: (context, idx) {
                      bool selected = idx == selectedDayIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedDayIndex = idx),
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            days[idx],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Timings",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 245),
                    Text(
                      "Price",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                // Slot Price Editing List (filtered to be between times and not off-hours)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: validSlotPriceIndices.length,
                  itemBuilder: (context, i) {
                    int idx = validSlotPriceIndices[i];
                    bool checked = slotSelectedMap[currentDay]![idx];
                    String slotName = slotRange(idx);
                    int price = slotPrices["$currentDay-$idx"] ?? 1000;
                    return Opacity(
                      opacity: checked ? 1.0 : 0.5,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: checked ? Color(0xFFe3f0ff) : const Color.fromARGB(255, 241, 240, 240),
                          border: Border.all(
                            color:
                                checked
                                    ? Color(0xFF2196F3)
                                    : const Color.fromARGB(255, 12, 12, 12),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow:
                              checked
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.08),
                                      blurRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: checked,
                              onChanged: (val) {
                                setState(() {
                                  slotSelectedMap[currentDay]![idx] =
                                      val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                slotName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "1000",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                controller: TextEditingController(
                                  text: price.toString(),
                                ),
                                onChanged: (val) {
                                  int p = int.tryParse(val) ?? price;
                                  if (syncPrice) {
                                    for (
                                      int i = 0;
                                      i < slotSelectedMap[currentDay]!.length;
                                      i++
                                    ) {
                                      if (slotSelectedMap[currentDay]![i])
                                        slotPrices["$currentDay-$i"] = p;
                                    }
                                  } else {
                                    slotPrices["$currentDay-$idx"] = p;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Sync price for all selected slots"),
                    Switch(
                      value: syncPrice,
                      onChanged: (val) => setState(() => syncPrice = val),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Enter UPI ID",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextField(
                  controller: upiIdOwner,
                  decoration: InputDecoration(hintText: "UPI ID"),
                ),
                SizedBox(height: 10),
                Text(
                  "Upload ID Proof",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: (){
                    _pickImages();
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          idProof != null
                              ? idProof!.path.split('/').last
                              : "Upload ID",
                        ),
                        Icon(Icons.autorenew),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                if (doEdit ? _fetchedImages.isNotEmpty:_idImages.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(doEdit ? _fetchedImages.length:_idImages.length, (index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 12),
                                  width: 100,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: doEdit ? NetworkImage("${_fetchedImages[index]}"): FileImage(File(_idImages[index].path)),
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
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async{
                    Map<String, List<Map<String, dynamic>>> slots = getSelectedSlotsWithPrices();
                    _downloadUrls= await _turfSlotService.uploadImages(_idImages,email);
                    for (var i = 0; i < _fetchedImages.length; i++) {
                      _downloadUrls.add(_fetchedImages[i]);
                    }
                    await _turfSlotService.saveTurfSlots(slotsData: slots, email_ID: email, turfName: turfName);
                    await _turfSlotService.saveTurfOwnerInfo(upiId: upiIdOwner.text.trim(), idProofUrl: _downloadUrls, email_ID: email, turfName: turfName);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) {
                          return ownerTurfRegisteredSuccessfulScreen();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  child: Text("Next", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeBox(String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue),
            SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            Spacer(),
            Text(time, style: TextStyle(fontWeight: FontWeight.w700)),
            Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
