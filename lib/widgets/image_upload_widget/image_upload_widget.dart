import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:upload_widget/widgets/image_upload_widget/provider.dart';

class ImageUploadWidget extends StatelessWidget {
  final int maxImages;
  final double imageWidth;
  final double imageHeight;
  final double maxFileSizeMB;

  final ImagePicker _picker = ImagePicker();

  ImageUploadWidget({
    super.key,
    this.maxImages = 5,
    this.imageWidth = 100,
    this.imageHeight = 100,
    this.maxFileSizeMB = 5, // default 5MB
  });

  Future<void> _pickImages(BuildContext context) async {
    final provider = Provider.of<ImageUploadProvider>(context, listen: false);
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      List<File> validFiles = [];
      for (var file in pickedFiles) {
        final f = File(file.path);
        final bytes = await f.length();
        final sizeMB = bytes / (1024 * 1024);
        if (sizeMB <= maxFileSizeMB) {
          validFiles.add(f);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${file.name} exceeds $maxFileSizeMB MB")),
          );
        }
      }

      if ((provider.selectedImages.length + validFiles.length) > maxImages) {
        final allowed = maxImages - provider.selectedImages.length;
        if (allowed > 0) {
          provider.addImages(validFiles.take(allowed).toList());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max $maxImages images allowed")),
        );
      } else {
        provider.addImages(validFiles);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageUploadProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImages(context),
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                "Pick Images (${provider.selectedImages.length}/$maxImages)",
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(provider.selectedImages.length, (index) {
                final file = provider.selectedImages[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => provider.removeImageAt(index),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
