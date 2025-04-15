import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isocial/module/ticket/controller/ticket_controller.dart';
import 'package:isocial/module/ticket/dispositon/DispositonController.dart';
import 'package:isocial/module/ticket/model/ticket_list_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../TicketConversation.dart';
import '../controller/auto_loader_controller.dart';

/*
  Activity name : TicketList activity
  Project name : iHelpBD CRM
  Auth : Eng.Sk Nayeem Ur Rahman
  Designation : Full Stack Software Developer
  Email : nayeemdeveloper@gmail.com
*/

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  TicketController controller = Get.put(TicketController());
  AutoLoaderController autoLoaderController = AutoLoaderController();

  @override
  void initState() {
    controller.fetchTicketList();
    controller.conversationBoxScrollToBottom();
    // autoLoaderController.ticketListLoader();
    //controller.conversationBoxScrollToBottom;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket List"),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18.sp,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                // Refresh ticket list with error handling
                try {
                  controller.fetchTicketList();
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

        if (controller.ticketList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No tickets found",
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () => controller.fetchTicketList(),
                  child: const Text("Refresh"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration.zero);
            controller.fetchTicketList();
          },
          child: ListView.separated(
              controller: controller.scrollController,
              itemBuilder: (_, index) {
                TicketListUIModel ticket = controller.ticketList[index];

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: Colors.grey, width: 0.5)),
                  child: ListTile(
                    // show ticket conversation
                    onTap: () async {
                      //set static variable
                      DispositionController.replayDataType =
                          ticket.dataType ?? "";

                      SharedPreferences ref =
                          await SharedPreferences.getInstance();

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
                                    // name
                                    pageName: ticket.name ?? "",
                                  )),
                        );
                      }
                    },

                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket.userName ?? "",
                            maxLines: 1,
                            style: TextStyle(fontSize: 17.sp),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5.w,
                              color: Colors.indigo,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(ticket.status ?? "",
                              style: TextStyle(
                                  color: Colors.indigo, fontSize: 12.sp)),
                        )
                      ],
                    ),

                    subtitle: Row(
                      children: [
                        Text(
                          ticket.dataType ?? "",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          " (${ticket.name ?? ""})",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) {
                return const SizedBox(height: 8);
              },
              itemCount: controller.ticketList.length),
        );
      }),
    );
  }
}
