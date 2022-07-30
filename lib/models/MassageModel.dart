// ignore_for_file: public_member_api_docs, sort_constructors_first
class MassageModel {
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;
  MassageModel({
    this.sender,
    this.text,
    this.seen,
    this.createdOn,
  });

  MassageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdOn = map["createdOn"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdOn": createdOn,
    };
  }
}
