import 'package:flutter/material.dart';

class Reusable {
  static Color getGreen() {
    return Color.fromRGBO(0, 200, 83, 1);
  }

  static Color getWhite() {
    return Colors.white;
  }

  static Color getBlack() {
    return Colors.black;
  }

 static Color getLightGreen() {
    return Color.fromRGBO(164, 255, 0, 1);
  }

   static Color getDarkModeBlack() {
    return Color.fromRGBO(18, 18, 18, 1);
  }

    static Color getDarkModeGrey() {
    return Color.fromRGBO(42, 42, 42, 1);
  }


  static Color getLightGrey() {
    return Color.fromRGBO(237, 237, 237, 1);
  }

  static Color getDarkGrey() {
    return Color.fromRGBO(81, 81, 81, 1);
  }

    static Color getTextGrey() {
    return Color.fromRGBO(109, 109, 109, 1);
  }

  static Color getLightBlue() {
    return Color.fromRGBO(0, 255, 255, 1);
  }

  static Color getDarkBlue() {
    return Color.fromRGBO(26, 34, 52, 1);
  }

  static double getDeviceHeight(BuildContext context,{ required double H}){
    return (MediaQuery.of(context).size.height)*(((H*100)/926)/100);
  }

  static double getDeviceWidth(BuildContext context,{ required double W}){
    return (MediaQuery.of(context).size.width)*(((W*100)/428)/100);
  }
}
