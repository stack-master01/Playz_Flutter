import 'package:flutter/material.dart';
import 'package:playz_user/View/owner_view/Login_Screen.dart';

class ownerPasswordResetScreen extends StatefulWidget {
  const ownerPasswordResetScreen({super.key});

  @override
  State<ownerPasswordResetScreen> createState() =>
      _ownerPasswordResetScreenState();
}

class _ownerPasswordResetScreenState extends State<ownerPasswordResetScreen> {
  TextEditingController ownerNewPassword = TextEditingController();
  TextEditingController ownerConformPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) {
                        return OwnerLoginScreen();
                      },
                    ),
                    (route) => false,
                  );
                },
                icon: Icon(
                  Icons.chevron_left_sharp,
                  color: Color.fromRGBO(13, 71, 161, 1),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(13, 71, 161, 1),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 328,
                child: TextField(
                  obscureText: true,
                  controller: ownerNewPassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.key,
                      color: Color.fromRGBO(13, 71, 161, 1),
                    ),
                    labelText: "New Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.visibility_off,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 328,
                child: TextField(
                  obscureText: true,
                  controller: ownerConformPassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.key,
                      color: Color.fromRGBO(13, 71, 161, 1),
                    ),
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.visibility_off,
                        color: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 328,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) {
                          return OwnerLoginScreen();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Save Password",
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
        ],
      ),
    );
  }
}
