import 'package:flutter/material.dart';

void showMessageBox(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Send Request?"),
        content: const Text(
          "Are you sure you want to send request to apply for security. ",
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(100, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),

              SizedBox(width: 10),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(100, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color.fromRGBO(237, 237, 237, 1),
                ),
                child: const Text("No", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      );
    },
  );
}
