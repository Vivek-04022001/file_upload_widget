import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:upload_widget/helper/download_and_save.dart';
import 'package:upload_widget/widgets/video_upload_widget.dart/provider.dart';
import 'package:upload_widget/widgets/video_upload_widget.dart/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoUploadWidget extends StatefulWidget {
  final int maxFiles;
  final double maxFileSizeMB;

  const VideoUploadWidget({
    super.key,
    this.maxFiles = 3,
    this.maxFileSizeMB = 20,
  });

  @override
  State<VideoUploadWidget> createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  bool isDownloading = false;
  final TextEditingController urlController = TextEditingController();

  Future<void> _pickVideos(BuildContext context) async {
    final provider = Provider.of<VideoUploadProvider>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      List<File> validFiles = [];
      for (var file in result.files) {
        final f = File(file.path!);
        final bytes = await f.length();
        final sizeMB = bytes / (1024 * 1024);
        if (sizeMB <= widget.maxFileSizeMB) {
          validFiles.add(f);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${file.name} exceeds ${widget.maxFileSizeMB} MB"),
            ),
          );
        }
      }

      if ((provider.selectedVideos.length + validFiles.length) >
          widget.maxFiles) {
        final allowed = widget.maxFiles - provider.selectedVideos.length;
        if (allowed > 0) {
          provider.addVideos(validFiles.take(allowed).toList());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max ${widget.maxFiles} videos allowed")),
        );
      } else {
        provider.addVideos(validFiles);
      }
    }
  }

  Future<void> _downloadAndAdd(BuildContext context) async {
    if (urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a URL")));
      return;
    }
    setState(() => isDownloading = true);
    try {
      final file = await downloadAndSaveFile(
        urlController.text.trim(),
        urlController.text.trim().split('/').last,
      );
      if (!mounted) return;
      Provider.of<VideoUploadProvider>(
        context,
        listen: false,
      ).addVideos([file]);
      urlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  Future<Widget> _getVideoThumbnail(File videoFile) async {
    final thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 80,
      quality: 50,
    );
    return thumbPath != null
        ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                File(thumbPath),
                width: 120,
                height: 80,
                fit: BoxFit.cover,
              ),
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
            ],
          ),
        )
        : Container(
          width: 120,
          height: 80,
          color: Colors.black12,
          child: const Icon(Icons.play_circle_fill, size: 32),
        );
  }

  @override
  Widget build(BuildContext context) {
    urlController.text =
        "https://videos.pexels.com/video-files/3150419/3150419-uhd_2560_1440_30fps.mp4";
    return Consumer<VideoUploadProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickVideos(context),
                  icon: const Icon(Icons.video_library),
                  label: const Text("Upload From Device"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: "Paste video URL",
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          isDownloading
                              ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadAndAdd(context),
                              ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(provider.selectedVideos.length, (index) {
                final file = provider.selectedVideos[index];
                return FutureBuilder<Widget>(
                  future: _getVideoThumbnail(file),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        width: 120,
                        height: 80,
                        color: Colors.black12,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        InAppVideoPlayerScreen(videoFile: file),
                              ),
                            );
                          },
                          child: snapshot.data!,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => provider.removeVideoAt(index),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
