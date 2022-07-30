// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String? uid;
  String? userName;
  String? email;
  String? profilePic;
  UserModel({
    this.uid,
    this.userName,
    this.email,
    this.profilePic,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    userName = map["userName"];
    email = map["email"];
    profilePic = map["profilePic"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "userName": userName,
      "email": email,
      "profilePic": profilePic,
    };
  }
}
