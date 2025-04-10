import 'dart:convert';

class TicketListResponseModel {
  String? status;
  List<TicketListUIModel>? ticketList;

  TicketListResponseModel({this.status, this.ticketList});

  TicketListResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      ticketList = <TicketListUIModel>[];
      // Check if data is a List or a Map
      if (json['data'] is List) {
        json['data'].forEach((v) {
          ticketList!.add(TicketListUIModel.fromJson(v));
        });
      } else if (json['data'] is Map) {
        // Handle case where data is a Map instead of a List
        // This is a fallback and might need adjustment based on actual API response
        json['data'].forEach((key, v) {
          if (v is Map<String, dynamic>) {
            ticketList!.add(TicketListUIModel.fromJson(v));
          }
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    if (ticketList != null) {
      data['data'] = ticketList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TicketListUIModel {
  String? userName;
  String? name;
  String? dataType;
  String? uniqueId;
  String? commentId;
  String? pageId;
  String? status;

  TicketListUIModel(
      {this.userName,
      this.name,
      this.dataType,
      this.uniqueId,
      this.commentId,
      this.pageId,
      this.status});

  TicketListUIModel.fromJson(Map<String, dynamic> json) {
    userName = json['user_name'];
    name = json['name'];
    dataType = json['data_type'];
    uniqueId = json['unique_id'];
    commentId = json['comment_id'];
    pageId = json['page_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user_name'] = userName;
    data['name'] = name;
    data['data_type'] = dataType;
    data['unique_id'] = uniqueId;
    data['comment_id'] = commentId;
    data['page_id'] = pageId;
    data['status'] = status;
    return data;
  }

  @override
  String toString() => const JsonEncoder.withIndent(' ').convert(toJson());
}
