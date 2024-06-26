import 'dart:developer';
import 'dart:io';

import 'package:chat_app/app/data/chat_response.dart';
import 'package:chat_app/app/data/message_response.dart';
import 'package:chat_app/app/modules/home/views/docs_view.dart';
import 'package:chat_app/app/modules/register/controllers/register_controller.dart';
import 'package:chat_app/app/utils/firebase_services.dart';
import 'package:chat_app/app/utils/firebase_storage_services.dart';
import 'package:chat_app/app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final firestoreInstance = FirebaseFirestore.instance;
  RegisterController authController = Get.find<RegisterController>();
  var userObj;
  ChatUser? currentUser, otherUsre;
  String? docsPath;
  String? htmlContent;

  ImagePicker picker = ImagePicker();
  FireBaseStorageServices? fireBaseStorageServices;

  Future<File?> getImageFromGallery() async {
    final XFile? _file = await picker.pickImage(source: ImageSource.gallery);
    if (_file != null) {
      return File(_file.path);
    }
    return null;
  }

  Stream<QuerySnapshot> getUserDataStream() {
    return firestoreInstance
        .collection('users')
        .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  Future<bool> checkChatExists({
    required String uid1,
    required String uid2,
  }) async {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    log(chatID, name: "ChatId");
    final result = await FirestoreService().chatCollection.doc(chatID).get();

    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final doc = FirestoreService().chatCollection.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);
    await doc.set(chat);
  }

  Future<void> sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias?.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await sendChatMessage(currentUser!.id, otherUsre!.id, message);
      } else if (chatMessage.medias!.first.type == MediaType.video) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias?.first.url,
            messageType: MessageType.Video,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await sendChatMessage(currentUser!.id, otherUsre!.id, message);
      } else if (chatMessage.medias!.first.type == MediaType.file) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias?.first.url,
            messageType: MessageType.File,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await sendChatMessage(currentUser!.id, otherUsre!.id, message);
      }
    } else {
      Message message = Message(
          senderID: currentUser?.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt));
      await sendChatMessage(currentUser!.id, otherUsre!.id, message);
    }
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final doc = FirestoreService().chatCollection.doc(chatId);
    await doc.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Stream<DocumentSnapshot<Object?>>? getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    return FirestoreService().chatCollection.doc(chatId).snapshots();
  }

  List<ChatMessage> generateChatMsgList(List<Message> messages) {
    List<ChatMessage> chatMessges = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUsre!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
            ],
            createdAt: m.sentAt!.toDate());
      } else if (m.messageType == MessageType.Video) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUsre!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.video)
            ],
            createdAt: m.sentAt!.toDate());
      } else if (m.messageType == MessageType.File) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUsre!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.file)
            ],
            createdAt: m.sentAt!.toDate());
      } else {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUsre!,
            text: m.content!,
            createdAt: m.sentAt!.toDate());
      }
    }).toList();
    chatMessges.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessges;
  }

  Future<void> downloadPDF(String docUrl) async {
    try {
      String url = docUrl;
      final ref = FirebaseStorage.instance.refFromURL(url);
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/temp.pdf');

      if (tempFile.existsSync()) {
        await tempFile.delete();
      }

      await ref.writeToFile(tempFile);

      docsPath = tempFile.path;
      update();
      print(docsPath);
      Get.to(() => const DocsViewer());
    } catch (e) {
      print("Error downloading PDF: $e");
    }
  }

  Future<void> downloadDocx(docxUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(docxUrl);
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/temp.docx');

      if (tempFile.existsSync()) {
        await tempFile.delete();
      }

      await ref.writeToFile(tempFile);

      htmlContent = tempFile.path;
      if (htmlContent != null) {
        final result = await OpenFilex.open(htmlContent!);
        print(result.message);
      }
    } catch (e) {
      print("Error downloading DOCX: $e");
    }
  }

  void _shareFile() async {
    if (htmlContent != null) {
      await Share.shareFiles([htmlContent!], text: 'Check out this file!');
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void onReady() {
    fireBaseStorageServices = FireBaseStorageServices();
    // TODO: implement onReady
    super.onReady();
  }
}
