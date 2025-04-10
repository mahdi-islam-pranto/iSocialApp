class  TicketReplyModel {
  String? authorizedBy;
  String? replayId;
  String? replayName;
  String? replayPageId;
  String? replayDataType;
  String? ticketStatus;
  String? userName;
  String? dispositionType;
  String? dispositionCat;
  String? dispositionSubCat;
  String? labelId;
  String? messageData;

  TicketReplyModel(this.authorizedBy,this.replayId,this.replayName,this.replayPageId,this.replayDataType,
      this.ticketStatus,this.userName,this.dispositionType,this.dispositionCat,this.dispositionSubCat,
      this.labelId,this.messageData);

    TicketReplyModel.fromMap(Map<String, dynamic> map) {
    authorizedBy = map['authorized_by'];
    replayId = map['replay_id'];
    replayName = "replay_name";
    replayPageId = map['replay_page_id'];
    replayDataType = map['replay_data_type'];
    ticketStatus = map['ticket_status'];
    userName = map['username'];
    dispositionType = map['disposition_type'];
    dispositionCat = map['disposition_cat'];
    dispositionSubCat = map['disposition_sub_cat'];
    labelId = map['label_id'];
    messageData = map['message_data'];


  }

  Map<String, dynamic> toMap() {
    return {
      "authorized_by": authorizedBy,
      "replay_id": replayId,
      "replay_name":replayName,
      "replay_page_id": replayPageId,
      "replay_data_type": replayDataType,
      "ticket_status": ticketStatus,
      "username": userName,
      "disposition_type": dispositionType,
      "disposition_cat": dispositionCat,
      "disposition_sub_cat": dispositionSubCat,
      "label_id": labelId,
      "message_data": messageData
    };
  }
}
