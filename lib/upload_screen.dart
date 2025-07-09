import 'package:flutter/material.dart';
import 'package:upload_widget/widgets/audio_upload_widget.dart/audio_upload_widget.dart';
import 'package:upload_widget/widgets/document_upload_widget/document_upload_widget.dart';
import 'package:upload_widget/widgets/image_upload_widget/image_upload_widget.dart';
import 'package:upload_widget/widgets/video_upload_widget.dart/video_upload_widget.dart';

class MyUploadScreen extends StatelessWidget {
  const MyUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Images")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ImageUploadWidget(
              maxImages: 3,
              imageWidth: 80,
              imageHeight: 80,
              maxFileSizeMB: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DocumentUploadWidget(maxFiles: 3, maxFileSizeMB: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AudioUploadWidget(maxFiles: 3, maxFileSizeMB: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: VideoUploadWidget(maxFiles: 3, maxFileSizeMB: 30),
          ),
        ],
      ),
    );
  }
}
