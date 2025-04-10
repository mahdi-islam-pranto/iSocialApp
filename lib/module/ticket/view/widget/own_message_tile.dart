import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isocial/module/ticket/view/widget/attachment_tile.dart';
import '../../model/ticket_conversation_list.response.dart';

class OwnMessageTile extends StatelessWidget {
  final ConversationUIModel? conversation;
  const OwnMessageTile({super.key, this.conversation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                conversation?.commentCreatedTime?.time ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 5.w),
              Text(
                conversation?.commentCreatedTime?.date ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 20.w),
              Text(
                conversation?.userName ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 5.w),
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5)
                  ],
                ),
                child: const CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage("assets/images/ilogo.png"),
                ),
              ),
            ],
          ),
        ),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10, right: 2),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 230, 128, 243).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (conversation?.attachmentUrl != null)
                AttachmentTile(conversation: conversation),
              if (conversation?.message != null &&
                  conversation!.message!.isNotEmpty)
                SelectableText(conversation!.message!),
            ],
          ),
        ),
      ],
    );
  }
}
