import 'package:chat_app/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

class DocsViewer extends GetView<HomeController> {
  const DocsViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Docs viewer"),
      ),
      body: controller.docsPath != null
          ? PDFView(
              filePath: controller.docsPath,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
