// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMassage;
  ChatRoomModel({
    this.chatRoomId,
    this.participants,
    this.lastMassage,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    participants = map["participants"];
    lastMassage = map["lastMassage"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participants": participants,
      "lastMassage": lastMassage,
    };
  }
}
