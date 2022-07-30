// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatRoomModel {
  String? chatRoomId;
  List<String>? participants;
  ChatRoomModel({
    this.chatRoomId,
    this.participants,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    participants = map["participants"];
  }

  Map<String, dynamic> toMap() {
    return {"chatRoomId": chatRoomId, "participants": participants};
  }
}
