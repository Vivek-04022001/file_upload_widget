import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upload_widget/widgets/audio_upload_widget.dart/provider.dart';
import 'package:upload_widget/widgets/document_upload_widget/provider.dart';
import 'package:upload_widget/widgets/image_upload_widget/provider.dart';
import 'package:upload_widget/upload_screen.dart';
import 'package:upload_widget/widgets/video_upload_widget.dart/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => DocumentUploadProvider()),
        ChangeNotifierProvider(create: (_) => AudioUploadProvider()),
        ChangeNotifierProvider(create: (_) => VideoUploadProvider()),
        // Add more providers here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Removes the debug banner
        title: 'Upload Widget App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyUploadScreen(),
      ),
    ),
  );
}
