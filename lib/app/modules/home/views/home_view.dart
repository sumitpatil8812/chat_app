import 'dart:developer';

import 'package:chat_app/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat App'),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (contex) {
                        return AlertDialog(
                          content: const Text("Are your you want logout?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text("No")),
                            ElevatedButton(
                                style: const ButtonStyle(
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.red)),
                                onPressed: () {
                                  controller.signOut();
                                },
                                child: const Text("Yes"))
                          ],
                        );
                      });
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ))
          ],
        ),
        body: StreamBuilder(
            stream: controller.getUserDataStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Unable to load data");
              }
              if (snapshot.hasData && snapshot.data != null) {
                final userList = snapshot.data!.docs;
                return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          onTap: () async {
                            final chatExists = await controller.checkChatExists(
                                uid1: FirebaseAuth.instance.currentUser!.uid,
                                uid2: userList[index]['uid']);
                            log(chatExists.toString());
                            if (!chatExists) {
                              await controller.createNewChat(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userList[index]['uid']);
                            }
                            Get.toNamed(Routes.chatView,
                                arguments: userList[index]);
                          },
                          leading: CircleAvatar(
                            child: Center(
                              child: Text(
                                userList[index]['username'][0]
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          title: Text(userList[index]['username']),
                        ),
                      );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
