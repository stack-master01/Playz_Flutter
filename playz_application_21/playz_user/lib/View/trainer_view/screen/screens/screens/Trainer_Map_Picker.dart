import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';

class TrainerMapPickerPage extends StatefulWidget {
  final Function(LatLng, String) onLocationPicked;
  const TrainerMapPickerPage({super.key, required this.onLocationPicked});

  @override
  _TrainerMapPickerPageState createState() => _TrainerMapPickerPageState();
}

class _TrainerMapPickerPageState extends State<TrainerMapPickerPage> {
  GoogleMapController? mapController;
  LatLng? _pickedLocation;
  String _address = "Fetching current location...";
  TextEditingController _searchController = TextEditingController();
  List<AutocompletePrediction> predictions = [];

  late GooglePlace googlePlace;

  final String googleApiKey = "AIzaSyCox88YnMoz3kLiVpoGxAQxjpgk4nV9B_o"; // 🔑 Replace with your API key

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(googleApiKey);
    _getCurrentLocation();
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _address = "Location services are disabled.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _address = "Location permission denied.";
      });
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _address = "Location permissions permanently denied.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _pickedLocation = currentLatLng;
    });

    _updateLocation(currentLatLng);

    mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
  }

  /// Update marker + reverse geocode
  Future<void> _updateLocation(LatLng pos) async {
    setState(() => _pickedLocation = pos);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _address =
            "${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      } else {
        _address = "Unknown Location";
      }
    } catch (e) {
      _address = "Error fetching address";
    }
    setState(() {});
  }

  /// Search autocomplete
  void _autoCompleteSearch(String value) async {
    if (value.isNotEmpty) {
      var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
      }
    } else {
      setState(() {
        predictions = [];
      });
    }
  }

  /// Select place from search
  Future<void> _selectPrediction(AutocompletePrediction prediction) async {
    if (prediction.placeId != null) {
      var details = await googlePlace.details.get(prediction.placeId!);
      if (details != null && details.result != null) {
        final lat = details.result!.geometry!.location!.lat;
        final lng = details.result!.geometry!.location!.lng;
        final pos = LatLng(lat!, lng!);
        _updateLocation(pos);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));

        setState(() {
          _searchController.text = details.result!.name ?? "";
          predictions = [];
        });
      }
    }
  }

  /// Open directions in Google Maps
  void _openDirections() async {
    if (_pickedLocation != null) {
      final url =
          "https://www.google.com/maps/dir/?api=1&destination=${_pickedLocation!.latitude},${_pickedLocation!.longitude}&travelmode=driving";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        Color orange = Colors.deepOrange;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Reusable.getDarkModeBlack()),
            ),
            title: Text(
              "Pick Location",
              style: TextStyle(
                  color: Reusable.getDarkModeBlack()),
            ),
            backgroundColor: isDark ? orange : orange,
          ),
          body: _pickedLocation == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _pickedLocation!,
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) => mapController = controller,
                      onTap: _updateLocation,
                      markers: {
                        Marker(
                          markerId: const MarkerId("picked"),
                          position: _pickedLocation!,
                          draggable: true,
                          onDragEnd: _updateLocation,
                        ),
                      },
                    ),
                    Positioned(
                      top: 10,
                      left: 15,
                      right: 15,
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            style: TextStyle(
                                color: isDark ? orange : Reusable.getDarkGrey()),
                            cursorColor: isDark ? orange : orange,
                            decoration: InputDecoration(
                              hintText: "Search by Name",
                              hintStyle: TextStyle(
                                  color: isDark ? orange : Reusable.getDarkGrey()),
                              filled: true,
                              fillColor: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              suffixIcon: Icon(
                                Icons.search,
                                color: isDark ? orange : orange,
                                size: Reusable.getDeviceWidth(context, W: 30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark ? Reusable.getLightGrey() : Reusable.getLightGrey(),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Reusable.getDeviceWidth(context, W: 30),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark ? orange : orange,
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
                            onChanged: _autoCompleteSearch,
                          ),
                          Container(
                            color: (_searchController.text == "")
                                ? Colors.transparent
                                : isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: predictions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: (_searchController.text == "")
                                      ? Text("")
                                      : Text(
                                          predictions[index].description ?? "",
                                          style: TextStyle(
                                              color: isDark
                                                  ? orange
                                                  : Reusable.getBlack()),
                                        ),
                                  onTap: () => _selectPrediction(predictions[index]),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? orange : orange,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () {
                                if (_pickedLocation != null) {
                                  widget.onLocationPicked(
                                      _pickedLocation!, _address);
                                }
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: Reusable.getDeviceWidth(context, W: 5),
                                    right: Reusable.getDeviceWidth(context, W: 5)),
                                child: Text(
                                  _address.isEmpty
                                      ? "Pick a location"
                                      : "Select: $_address",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Reusable.getDarkModeBlack()
                                          ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? orange : orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _openDirections,
                            child: Icon(Icons.location_searching,
                                size: Reusable.getDeviceWidth(context, W: 30),
                                color: Reusable.getDarkModeBlack()
                                    ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        );
      });
  }
}
