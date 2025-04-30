import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../model/wa_conversation_model.dart';
import 'wa_attachtmentTile.dart';

class WaOwnermassage extends StatelessWidget {
  final WhatsAppMessage? ownerConversation;
  final String? displayPhoneNumber;

  const WaOwnermassage(
      {super.key, this.ownerConversation, this.displayPhoneNumber});

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
                ownerConversation?.time ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 5.w),
              Text(
                ownerConversation?.date ?? "",
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              ),
              SizedBox(width: 20.w),
              Text(
                displayPhoneNumber ?? "",
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
                  radius: 13,
                  backgroundImage: AssetImage("assets/images/ilogo.png"),
                ),
              ),
            ],
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10, right: 2),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 12, 188, 121).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ownerConversation?.mediaUrl != null &&
                  ownerConversation!.mediaUrl!.isNotEmpty)
                WaAttachmentTile(waUserConversation: ownerConversation),
              SizedBox(
                  height: ownerConversation?.mediaUrl != null &&
                          ownerConversation!.mediaUrl!.isNotEmpty
                      ? 8.h
                      : 0),
              if (ownerConversation?.body != null &&
                  ownerConversation!.body!.isNotEmpty)
                SelectableText(
                  ownerConversation!.body!,
                  style: const TextStyle(color: Colors.black),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
