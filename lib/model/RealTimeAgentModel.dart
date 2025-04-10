
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isocial/view/AllPost.dart';

class RealTimeAgentModel {
  final String userName;
  final String status;
  final String startTime;
  final int newTicket;
  final int progressTicket;
  final int closedTicket;
  final int totalTicket;


  RealTimeAgentModel(this.userName, this.status, this.startTime, this.newTicket,
      this.progressTicket, this.closedTicket, this.totalTicket);

  DataRow getRow(
      SelectedCallBack callback,
      List<String> selectedIds,
      ) {
    return DataRow(
      cells: [
        DataCell(Text(userName)),
        DataCell(Text(status)),
        DataCell(Text(startTime)),
        DataCell(Text(totalTicket.toString())),
        DataCell(Text(newTicket.toString())),
        DataCell(Text(progressTicket.toString())),
        DataCell(Text(closedTicket.toString())),

      ],
     // onSelectChanged: (newState) {
       // callback(userName, newState ?? false);
      //},
      //selected: selectedIds.contains(userName),
    );
  }

  factory RealTimeAgentModel.fromJson(Map<String, dynamic> json) {
    return RealTimeAgentModel(
      json['user'] as String,
      json['status'] as String,
      json['start_time'] as String,
      json['newTicket'] as int,
      json['progressTicket'] as int,
      json['closedTicket'] as int,
      json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {

    return {
      "user": userName,
      "status": status,
      'start_time': startTime,
      'newTicket': newTicket,
      'progressTicket': progressTicket,
      'closedTicket': closedTicket,
      'total': totalTicket,
    };
  }

}
