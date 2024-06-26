import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FireBaseStorageServices {
  FireBaseStorageServices._internal();
  static FireBaseStorageServices get instance =>
      FireBaseStorageServices._internal();
  factory FireBaseStorageServices() {
    return instance;
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatId}) async {
    Reference fileRef = FirebaseStorage.instance
        .ref("chats/$chatId")
        .child("${DateTime.now().toIso8601String()}${p.extension(file.path)}");

    UploadTask task = fileRef.putFile(file);
    return task.then((val) {
      if (val.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
    });
  }

  Future<String?> uploadVideo(File file, String chatId) async {
    Reference fileRef = FirebaseStorage.instance
        .ref("chats/$chatId")
        .child("${DateTime.now().toIso8601String()}${p.extension(file.path)}");

    UploadTask task = fileRef.putFile(file);
    return task.then((val) {
      if (val.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
    });
  }

  Future<String?> uploadDocs(File file, String chatId) async {
    Reference fileRef = FirebaseStorage.instance
        .ref("chats/$chatId")
        .child("${DateTime.now().toIso8601String()}${p.extension(file.path)}");

    UploadTask task = fileRef.putFile(file);
    TaskSnapshot taskSnapshot = await task;
    return fileRef.getDownloadURL();

    // return task.then((val) {
    //   if (val.state == TaskState.success) {
    //     return fileRef.getDownloadURL();
    //   }
    // });
  }
}
