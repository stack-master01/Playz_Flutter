class OwnerRegisterModel {
  String userName;
  String email_ID;
  String contact_Number;
  String password;
  OwnerRegisterModel({required this.userName,required this.email_ID,required this.contact_Number,required this.password});
  Map<String,dynamic> toMAp(){
    return{
      "userName":userName,"email_ID":email_ID,"contact_Number":contact_Number,"password":password,
    };
  }
}