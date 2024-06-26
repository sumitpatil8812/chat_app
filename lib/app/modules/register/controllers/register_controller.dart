import 'dart:developer';

import 'package:chat_app/app/data/chat_response.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:chat_app/app/utils/firebase_services.dart';
import 'package:chat_app/app/utils/firebase_storage_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Rx<User?> firebaseUser;
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  RxBool isLoading = false.obs;
  // CollectionReference? chatCollection;
  CollectionReference? userCollection;
  RxBool obScure = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void signUp(String email, String password, String username) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        "uid": userCredential.user!.uid,
        'createdAt': Timestamp.now(),
      });

      FirestoreService().chatCollection;

      emailController.clear();
      passwordController.clear();
      usernameController.clear();
    } catch (e) {
      Get.snackbar("Sign Up Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
    isLoading.value = false;
  }

  void signIn(String email, String password) async {
    isLoading.value = true;
    log(isLoading.value.toString());
    update();

    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        loginEmailController.clear();
        loginPasswordController.clear();
      });
    } catch (e) {
      Get.snackbar("Sign In Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
    isLoading.value = false;
    log(isLoading.value.toString());

    update();
  }
}
