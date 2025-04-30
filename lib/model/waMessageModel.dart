class MessageModel {
  String? userName;
  String? message;
  String? commentCreatedTime;
  String? date;
  String? time;
  String? userId;
  String? senderType;
  String? attachmentType;
  String? attachmentUrl;

  MessageModel(this.userName, this.message, this.commentCreatedTime,
      this.userId, this.senderType, this.attachmentType, this.attachmentUrl);

  MessageModel.fromMap(Map<String, dynamic> map) {
    userName = map['user_name'];
    message = map['message'];
    commentCreatedTime = "10:20 Feb 8, 2023";
    date = map['comment_created_time']['date'];
    time = map['comment_created_time']['time'];
    userId = map['user_id'];
    senderType = map['sender_type'];
    attachmentType = map['attachment_type'];
    attachmentUrl = map['attachment_url'];
  }

  Map<String, dynamic> toMap() {
    return {
      "user_name": userName,
      "message": message,
      "commentCreatedTime": commentCreatedTime,
      "user_id": userId,
      "sender_type": senderType,
      "attachment_type": attachmentType,
      "attachment_url": attachmentUrl
    };
  }
}
