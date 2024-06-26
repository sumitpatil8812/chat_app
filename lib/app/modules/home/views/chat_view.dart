import 'dart:io';

import 'package:chat_app/app/data/chat_response.dart';
import 'package:chat_app/app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/app/modules/home/views/docs_view.dart';
import 'package:chat_app/app/utils/utils.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends GetView<HomeController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(initState: (state) {
      controller.userObj = Get.arguments;

      controller.currentUser = ChatUser(
          id: FirebaseAuth.instance.currentUser!.uid,
          firstName: FirebaseAuth.instance.currentUser!.displayName);

      controller.otherUsre = ChatUser(
        id: controller.userObj['uid'],
        firstName: controller.userObj['username'],
      );
    }, builder: (ct) {
      return Scaffold(
          appBar: AppBar(
            title: Text(controller.userObj['username']),
          ),
          body: StreamBuilder(
              stream: controller.getChatData(
                  controller.currentUser!.id, controller.otherUsre!.id),
              builder: (context, snapshot) {
                Chat? chat = snapshot.data?.data() as Chat?;
                List<ChatMessage> messages = [];
                if (chat != null && chat.messages != null) {
                  messages = controller.generateChatMsgList(chat.messages!);
                }
                return DashChat(
                    messageOptions: MessageOptions(
                        onTapMedia: (media) {
                          String url = media.url;

                          print(url);
                          if (url.contains('.pdf')) {
                            controller.downloadPDF(url);
                          } else {
                            controller.downloadDocx(url);
                          }
                        },
                        showOtherUsersAvatar: true,
                        showTime: true),
                    inputOptions: InputOptions(alwaysShowSend: true, trailing: [
                      IconButton(
                          onPressed: () async {
                            mediaBottomSheet();
                          },
                          icon: Icon(Icons.attach_file_rounded))
                    ]),
                    currentUser: controller.currentUser!,
                    onSend: (msg) {
                      controller.sendMessage(msg);
                    },
                    messages: messages);
              }));
    });
  }

  Future<T?> mediaBottomSheet<T>() async {
    return Get.bottomSheet(
        backgroundColor: Colors.white,
        SizedBox(
          height: Get.height * 0.15,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                      radius: 35,
                      child: IconButton(
                          onPressed: () async {
                            Get.back();
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                            );
                            if (result != null) {
                              File file = File(result.files.single.path!);
                              String chatId = generateChatId(
                                  uid1: controller.currentUser!.id,
                                  uid2: controller.otherUsre!.id);
                              String? docsDownloadUrl = await controller
                                  .fireBaseStorageServices
                                  ?.uploadDocs(file, chatId);
                              if (docsDownloadUrl != null) {
                                ChatMessage chatMessage = ChatMessage(
                                    user: controller.currentUser!,
                                    createdAt: DateTime.now(),
                                    medias: [
                                      ChatMedia(
                                          url: docsDownloadUrl,
                                          fileName: "",
                                          type: MediaType.file)
                                    ]);
                                controller.sendMessage(chatMessage);
                              }
                            }
                          },
                          icon: Icon(Icons.file_copy))),
                  CircleAvatar(
                      radius: 35,
                      child: IconButton(
                          onPressed: () async {
                            Get.back();
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.video,
                            );
                            if (result != null) {
                              File file = File(result.files.single.path!);
                              String chatId = generateChatId(
                                  uid1: controller.currentUser!.id,
                                  uid2: controller.otherUsre!.id);
                              String? vidDownloadUrl = await controller
                                  .fireBaseStorageServices
                                  ?.uploadVideo(file, chatId);
                              if (vidDownloadUrl != null) {
                                ChatMessage chatMessage = ChatMessage(
                                    user: controller.currentUser!,
                                    createdAt: DateTime.now(),
                                    medias: [
                                      ChatMedia(
                                          url: vidDownloadUrl,
                                          fileName: "",
                                          type: MediaType.video)
                                    ]);
                                controller.sendMessage(chatMessage);
                              }
                            }
                          },
                          icon: Icon(Icons.video_call))),
                  CircleAvatar(
                      radius: 35,
                      child: IconButton(
                          onPressed: () async {
                            Get.back();
                            File? file = await controller.getImageFromGallery();
                            if (file != null) {
                              String chatId = generateChatId(
                                  uid1: controller.currentUser!.id,
                                  uid2: controller.otherUsre!.id);
                              String? downloadUrl = await controller
                                  .fireBaseStorageServices
                                  ?.uploadImageToChat(
                                      file: file, chatId: chatId);

                              if (downloadUrl != null) {
                                ChatMessage chatMessage = ChatMessage(
                                    user: controller.currentUser!,
                                    createdAt: DateTime.now(),
                                    medias: [
                                      ChatMedia(
                                          url: downloadUrl,
                                          fileName: "",
                                          type: MediaType.image)
                                    ]);
                                controller.sendMessage(chatMessage);
                              }
                            }
                          },
                          icon: Icon(Icons.image))),
                ],
              )
            ],
          ),
        ));
  }
}
