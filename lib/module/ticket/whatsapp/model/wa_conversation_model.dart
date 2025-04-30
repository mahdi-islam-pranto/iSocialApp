class WhatsAppMessage {
  final String? replierId;
  final String? replierName;
  final String? date;
  final String? time;
  final String? profileName;
  final String? body;
  String? type;
  final String? senderType;
  String? mediaUrl;
  late final String? mediaName;
  String? mimeType;
  final String? extension;
  final String? localUrl;
  final String? logAssignUser;

  WhatsAppMessage({
    this.replierId,
    this.replierName,
    this.date,
    this.time,
    this.profileName,
    this.body,
    this.type,
    this.senderType,
    this.mediaUrl,
    this.mediaName,
    this.mimeType,
    this.extension,
    this.localUrl,
    this.logAssignUser,
  });

  factory WhatsAppMessage.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessage(
      replierId: json['replier_id'],
      replierName: json['replier_name'],
      date: json['created_time']['date'] ?? '',
      time: json['created_time']['time'] ?? '',
      profileName: json['profile_name'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      senderType: json['sender_type'] ?? '',
      mediaUrl: json['media_url'],
      mediaName: json['media_name'],
      mimeType: json['mime_type'],
      extension: json['extension'],
      localUrl: json['local_url'],
      logAssignUser: json['log_assign_user'],
    );
  }

  @override
  String toString() {
    return 'WhatsAppMessage(from: $replierName, date: $date, time: $time, body: $body, type: $type, mediaUrl: $mediaUrl, mimeType: $mimeType)';
  }
}
