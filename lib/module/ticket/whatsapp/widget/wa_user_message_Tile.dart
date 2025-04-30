import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../dispositon/DispositonController.dart';
import '../model/wa_conversation_model.dart';
import 'wa_attachtmentTile.dart';

class WaUserMessage extends StatelessWidget {
  final WhatsAppMessage? userConversation;
  const WaUserMessage({super.key, this.userConversation});

  @override
  Widget build(BuildContext context) {
    DispositionController.replayName = userConversation?.profileName ?? "";

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
                child: const CircleAvatar(
                  radius: 17,
                  backgroundImage: AssetImage("assets/images/wa.jpg"),
                ),
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  userConversation?.profileName ?? "",
                  maxLines: 1,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black45),
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                userConversation?.time ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 5.w),
              Text(
                userConversation?.date ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              )
            ],
          ),
        ),
        // msg
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10, left: 2),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(162, 229, 252, 0.4470588235294118),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userConversation?.mediaUrl != null &&
                  userConversation!.mediaUrl!.isNotEmpty)
                WaAttachmentTile(waUserConversation: userConversation),
              SizedBox(
                  height: userConversation?.mediaUrl != null &&
                          userConversation!.mediaUrl!.isNotEmpty
                      ? 8.h
                      : 0),
              if (userConversation?.body != null &&
                  userConversation!.body!.isNotEmpty)
                SelectableText(
                  userConversation!.body!,
                  style: const TextStyle(color: Colors.black),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
