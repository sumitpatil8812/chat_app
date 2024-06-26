import 'package:chat_app/app/modules/register/controllers/register_controller.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends GetView<RegisterController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(builder: (ct) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Log in'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: controller.isLoading.value
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ))
              : Column(
                  children: [
                    TextFormField(
                      controller: controller.loginEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        errorBorder: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: controller.loginPasswordController,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          enabledBorder: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(),
                          errorBorder: const OutlineInputBorder(),
                          suffixIcon: InkWell(
                            onTap: () {
                              controller.obScure.toggle();
                              controller.update();
                            },
                            child: Icon(controller.obScure.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                          )),
                      obscureText: controller.obScure.value,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        controller.signIn(
                          controller.loginEmailController.text.trim(),
                          controller.loginPasswordController.text.trim(),
                        );
                      },
                      child: const Text('Log in'),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Dont have an account? "),
                        InkWell(
                          onTap: () {
                            Get.toNamed(Routes.REGISTER);
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    )
                  ],
                ),
        ),
      );
    });
  }
}
