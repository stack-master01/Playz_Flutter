import 'package:flutter/material.dart';

class CustomSnackbar {
  showCustomSnackbar(BuildContext context , String message ,{Color bgColour = Colors.green}){
    ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text(message),backgroundColor: bgColour,));
  }
}