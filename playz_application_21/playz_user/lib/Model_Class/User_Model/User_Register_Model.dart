class UserRegisterModel{
  String? contact_Number;
  String? userName;
  String? email_ID;
  String? password;


  UserRegisterModel({required this.contact_Number,required this.password,required this.email_ID,required this.userName});

  Map<String,dynamic> getUserRegisterDetails(){
    return {
      "contact_Number":?contact_Number,
      "userName":?userName,
      "email_ID":?email_ID,
      "password":?password,
    };
  }
}