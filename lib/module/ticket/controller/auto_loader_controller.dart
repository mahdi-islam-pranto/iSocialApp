import 'dart:async';

import 'package:get/get.dart';
import 'package:isocial/module/ticket/controller/ticket_controller.dart';

class AutoLoaderController {
  TicketController ticketController = Get.find();

  late Timer timer;
  void start() {
    const oneSec = Duration(seconds: 5);
    timer = Timer.periodic(
        oneSec, (Timer t) => ticketController.getTicketConversation());
  }

  void stop() {
    if (timer.isActive) {
      timer.cancel();
    }
  }
}
