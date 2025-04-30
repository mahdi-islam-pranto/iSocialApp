// models/ticket_model.dart
class WaTicketModel {
  final String displayPhoneNumber;
  final String waId;
  final String userName;
  final String phoneNumberId;
  final String status;
  final String assignUser;

  WaTicketModel({
    required this.displayPhoneNumber,
    required this.waId,
    required this.userName,
    required this.phoneNumberId,
    required this.status,
    required this.assignUser,
  });

  factory WaTicketModel.fromJson(Map<String, dynamic> json) {
    return WaTicketModel(
      displayPhoneNumber: json['display_phone_number'],
      waId: json['wa_id'],
      userName: json['user_name'],
      phoneNumberId: json['phone_number_id'],
      status: json['status'],
      assignUser: json['assign_user'],
    );
  }

  /// Used to compare for new tickets
  String get uniqueId => waId;
}
