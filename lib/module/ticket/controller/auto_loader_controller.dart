import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:isocial/module/ticket/controller/ticket_controller.dart';

class AutoLoaderController {
  TicketController ticketController = Get.find();

  Timer? conversationTimer;
  Timer? ticketListTimer;

  // Start auto-loading for conversation
  void start() {
    const oneSec = Duration(seconds: 5);
    conversationTimer = Timer.periodic(
        oneSec, (Timer t) => ticketController.getTicketConversation());
  }

  // Stop auto-loading for conversation
  void stop() {
    if (conversationTimer != null && conversationTimer!.isActive) {
      conversationTimer!.cancel();
    }
  }

  // Start auto-loading for ticket list
  void ticketListLoader() {
    log('Starting ticket list auto-loader');
    // Check every 10 seconds for new tickets
    const refreshInterval = Duration(seconds: 10);
    ticketListTimer = Timer.periodic(refreshInterval, (Timer t) {
      log('Auto-refreshing ticket list');
      ticketController.fetchTicketList(isAutoRefresh: true);
    });
  }

  // Stop auto-loading for ticket list
  void stopTicketListLoader() {
    if (ticketListTimer != null && ticketListTimer!.isActive) {
      log('Stopping ticket list auto-loader');
      ticketListTimer!.cancel();
    }
  }

  // Dispose all timers
  void dispose() {
    stop();
    stopTicketListLoader();
  }
}
