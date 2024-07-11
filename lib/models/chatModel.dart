class ChatModel {
  String? message;
  String? sendBy;
  int? time;

  ChatModel({this.message, this.time, this.sendBy});

  Map<String, dynamic> toJson() {
    return {"message": message, "time": time, "sendBy": sendBy};
  }

  factory ChatModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatModel(
        message: map["message"], time: map["time"], sendBy: map["sendBy"]);
  }
}
