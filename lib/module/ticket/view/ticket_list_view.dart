import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isocial/module/ticket/controller/ticket_controller.dart';
import 'package:isocial/module/ticket/dispositon/DispositonController.dart';
import 'package:isocial/module/ticket/model/ticket_list_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../storage/sharedPrefs.dart';
import '../TicketConversation.dart';
import '../controller/auto_loader_controller.dart';
import '../whatsapp/model/wa_list_model.dart';
import '../whatsapp/wahtsapp_ticket_conversation.dart';

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  TicketController controller = Get.put(TicketController());
  late AutoLoaderController autoLoaderController;

  @override
  void initState() {
    super.initState();
    controller.fetchTicketList();
    controller.fetchwaTicketList();

    controller.conversationBoxScrollToBottom();

    autoLoaderController = AutoLoaderController();
    autoLoaderController.ticketListLoader();
    autoLoaderController.waTicketListLoader();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map;
        if (args.containsKey('showSnackbar') && args['showSnackbar'] == true) {
          final message = args['message'] as String? ?? 'Operation successful';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      String? transferMessage =
          SharedPrefs.getString("transfer_success_message");
      if (transferMessage != null && transferMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transferMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        SharedPrefs.remove("transfer_success_message");
      }
    });
  }

  @override
  void dispose() {
    autoLoaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Ticket List"),
                if (controller.isAutoRefreshing.value)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 15,
                    height: 15,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            )),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 18.sp),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                try {
                  controller.fetchTicketList(isAutoRefresh: false);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error refreshing: $e')),
                  );
                }
              },
              icon: const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.blue,
                child: Icon(Icons.refresh, color: Colors.white),
              ),
            ),
          )
        ],
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchTicketList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  /// Facebook Ticket Section
                  if (controller.ticketList.isNotEmpty) ...[
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text("Facebook Tickets",
                    //       style: TextStyle(
                    //           fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    // ),
                    // const SizedBox(height: 10),
                    ...controller.ticketList
                        .map((ticket) => buildFacebookTicket(ticket))
                        .toList(),
                  ] else
                    buildEmptySection(""),

                  // const SizedBox(height: 30),

                  /// WhatsApp Ticket Section
                  if (controller.waTicketList.isNotEmpty) ...[
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text("WhatsApp Tickets",
                    //       style: TextStyle(
                    //           fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    // ),
                    // const SizedBox(height: 10),
                    ...controller.waTicketList
                        .map((wa) => buildWaTicket(wa))
                        .toList(),
                  ] else
                    buildEmptySection(""),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 15.sp, color: Colors.grey),
        ),
      ),
    );
  }

  Widget buildFacebookTicket(TicketListUIModel ticket) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(Icons.facebook, color: Colors.blue, size: 25.sp),
        onTap: () async {
          DispositionController.replayDataType = ticket.dataType ?? "";
          SharedPreferences ref = await SharedPreferences.getInstance();
          ref.setString("uniqueId", ticket.uniqueId ?? "");
          ref.setString("dataType", ticket.dataType ?? "");
          ref.setString("commentId", ticket.commentId ?? "");
          ref.setString("pageId", ticket.pageId ?? "");
          ref.setString("name", ticket.name ?? "");

          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TicketConversation(
                  fullName: ticket.userName ?? "",
                  dataType: ticket.dataType ?? "",
                  pageName: ticket.name ?? "",
                ),
              ),
            );
          }
        },
        title: Row(
          children: [
            Expanded(
              child: Text(ticket.userName ?? "",
                  maxLines: 1, style: TextStyle(fontSize: 17.sp)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(width: 0.5.w, color: Colors.indigo),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ticket.status ?? "",
                style: TextStyle(color: Colors.indigo, fontSize: 12.sp),
              ),
            )
          ],
        ),
        subtitle: Row(
          children: [
            Text(ticket.dataType ?? "",
                style: const TextStyle(color: Colors.grey)),
            Text(" (${ticket.name ?? ""})",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildWaTicket(WaTicketModel waTicket) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage("assets/images/wa.jpg"),
        ),
        onTap: () async {
          DispositionController.replayDataType = waTicket.userName ?? "";
          SharedPreferences ref = await SharedPreferences.getInstance();
          ref.setString("waId", waTicket.waId ?? "");
          ref.setString("assignUser", waTicket.assignUser ?? "");
          ref.setString("userName", waTicket.userName ?? "");
          ref.setString(
              "displayPhoneNumber", waTicket.displayPhoneNumber ?? "");
          ref.setString("phoneNumberId", waTicket.phoneNumberId ?? "");

          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WhatsappConversion(
                  userName: waTicket.userName ?? "",
                  pageNumber: waTicket.displayPhoneNumber ?? "",
                  assignUser: waTicket.assignUser ?? "",
                  wa_id: waTicket.waId,
                ),
              ),
            );
          }
        },
        title: Row(
          children: [
            Expanded(
              child: Text(waTicket.userName ?? "",
                  maxLines: 1, style: TextStyle(fontSize: 17.sp)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(width: 0.5.w, color: Colors.indigo),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                waTicket.status ?? "",
                style: TextStyle(color: Colors.indigo, fontSize: 12.sp),
              ),
            )
          ],
        ),
        subtitle: Row(
          children: [
            Text(waTicket.waId ?? "",
                style: const TextStyle(color: Colors.grey)),
            Text(" (${waTicket.assignUser ?? ""})",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
