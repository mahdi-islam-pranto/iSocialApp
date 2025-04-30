import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:isocial/module/ticket/controller/ticket_controller.dart';

import '../../../storage/sharedPrefs.dart';

class AutoLoaderController {
  TicketController ticketController = Get.find();

  Timer? conversationTimer;
  Timer? ticketListTimer;

  Timer? waconversationTimer;
  Timer? waTicketListTimer;
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

  // Stop wa auto-loading for conversation
  void waStop() {
    if (waconversationTimer != null && waconversationTimer!.isActive) {
      waconversationTimer!.cancel();
    }
  }

  // Start auto-loading whatsapp  for conversation
  void waAutoloderStart() {
    const oneSec = Duration(seconds: 5);
    String waId = SharedPrefs.getString("waId") ?? "";

    if (waId.isEmpty) {
      log("WhatsApp waId is missing. Auto-loader not started.");
      return;
    }

    log("Starting WhatsApp auto-loader with waId: $waId");

    waconversationTimer = Timer.periodic(oneSec, (Timer t) {
      try {
        log("Fetching WhatsApp conversation for waId: $waId");
        // ticketController.getWatsappTicketConversation(waId);
        ticketController.getWatsappTicketConversation();
      } catch (e, st) {
        log("Error in WhatsApp auto-loader: >>>>>>>>>>>>>$e");
        log("Stacktrace: $st");
      }
    });
  }

  // Start auto-loading for ticket list
  void ticketListLoader() {
    log('Starting ticket list auto-loader');
    // Check every 10 seconds for new tickets
    const refreshInterval = Duration(seconds: 4);
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

  // whatsapp  ticket list loader
  void waTicketListLoader() {
    log('Starting ticket list auto-loader');
    // Check every 10 seconds for new tickets
    const refreshInterval = Duration(seconds: 4);
    waTicketListTimer = Timer.periodic(refreshInterval, (Timer t) {
      log('Auto-refreshing ticket list');
      ticketController.fetchwaTicketList(isAutoRefresh: true);
    });
  }

  // Dispose all timers
  void dispose() {
    stop();
    stopTicketListLoader();
  }
}
