import 'package:flutter/material.dart';

class DispositionController {
  static TextEditingController dispositionController = TextEditingController();

  //Ticket replay data

  static String attachmentData = "";
  static String messageData = "";
  static String replayDataType = "";
  static String replayId = "";
  static String replayName = "";
  static String replayPageId = "";
  static String ticketStatus = "";
  static String dispositionType = "";
  static String dispositionCat = "";
  static String dispositionSubCat = "";
  static String labelId = "";
  static String userName = "";

  static void clearData() {
    dispositionController.clear();
    messageData = "";
    ticketStatus = "";
    dispositionType = "";
    dispositionCat = "";
    dispositionSubCat = "";
    labelId = "";
  }
}
