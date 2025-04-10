import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isocial/module/ticket/view/widget/attachment_tile.dart';
import '../../dispositon/DispositonController.dart';
import '../../model/ticket_conversation_list.response.dart';

class UserMessageTile extends StatelessWidget {
  final ConversationUIModel? conversation;
  const UserMessageTile({super.key, this.conversation});

  @override
  Widget build(BuildContext context) {
    DispositionController.replayName = conversation?.userName ?? "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5),
                  ],
                ),
                child: Icon(
                  Icons.facebook,
                  color: Colors.blue,
                  size: 42.sp,
                ),
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  conversation?.userName ?? "",
                  maxLines: 1,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black45),
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                conversation?.commentCreatedTime?.time ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 5.w),
              Text(
                conversation?.commentCreatedTime?.date ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              )
            ],
          ),
        ),
        // msg
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10, left: 2),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(162, 229, 252, 0.4470588235294118),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (conversation?.attachmentUrl != null)
                AttachmentTile(conversation: conversation),
              if (conversation?.message != null &&
                  conversation!.message!.isNotEmpty)
                SelectableText(
                  conversation!.message!,
                  style: const TextStyle(color: Colors.black),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
