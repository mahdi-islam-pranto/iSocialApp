class TicketConversationListResponseModel {
  String? status;
  Data? data;

  TicketConversationListResponseModel({this.status, this.data});

  TicketConversationListResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<ConversationUIModel>? conversationList;

  Data({this.conversationList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      conversationList = <ConversationUIModel>[];
      json['result'].forEach((v) {
        conversationList!.add(ConversationUIModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (conversationList != null) {
      data['result'] = conversationList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ConversationUIModel {
  String? userName;
  String? message;
  CommentCreatedTime? commentCreatedTime;
  String? userId;
  String? senderType;
  String? attachmentType;
  String? attachmentUrl;
  String? localFilePath; // Local file path for display
  String? localFileName;
  String?
      uploadStatus; // Status of the upload (null, 'uploading', 'uploaded', 'failed')

  ConversationUIModel({
    this.userName,
    this.message,
    this.commentCreatedTime,
    this.userId,
    this.senderType,
    this.attachmentType,
    this.attachmentUrl,
    this.localFilePath,
    this.localFileName,
    this.uploadStatus,
  });

  ConversationUIModel.fromJson(Map<String, dynamic> json) {
    userName = json['user_name'];
    message = json['message'];
    commentCreatedTime = json['comment_created_time'] != null
        ? CommentCreatedTime.fromJson(json['comment_created_time'])
        : null;
    userId = json['user_id'];
    senderType = json['sender_type'];
    attachmentType = json['attachment_type'];
    attachmentUrl = json['attachment_url'];
    localFilePath = json['local_file_path'];
    localFileName = json['local_file_name'];
    uploadStatus = json['upload_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user_name'] = userName;
    data['message'] = message;
    if (commentCreatedTime != null) {
      data['comment_created_time'] = commentCreatedTime!.toJson();
    }
    data['user_id'] = userId;
    data['sender_type'] = senderType;
    data['attachment_type'] = attachmentType;
    data['attachment_url'] = attachmentUrl;
    data['local_file_path'] = localFilePath;
    data['local_file_name'] = localFileName;
    data['upload_status'] = uploadStatus;
    return data;
  }
}

class CommentCreatedTime {
  String? date;
  String? time;

  CommentCreatedTime({this.date, this.time});

  CommentCreatedTime.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['date'] = date;
    data['time'] = time;
    return data;
  }
}
