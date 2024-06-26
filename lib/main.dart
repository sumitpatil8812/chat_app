import 'package:chat_app/app/modules/register/bindings/register_binding.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:chat_app/app/utils/firebase_services.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirestoreService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Chat App",
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? Routes.HOME
          : Routes.LOGIN,
      getPages: AppPages.routes,
      initialBinding: RegisterBinding(),
    );
  }
}
