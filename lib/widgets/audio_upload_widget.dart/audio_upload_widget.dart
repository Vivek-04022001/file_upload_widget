import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:upload_widget/helper/download_and_save.dart';
import 'package:upload_widget/widgets/audio_upload_widget.dart/provider.dart';

class AudioUploadWidget extends StatefulWidget {
  final int maxFiles;
  final double maxFileSizeMB;

  const AudioUploadWidget({
    super.key,
    this.maxFiles = 5,
    this.maxFileSizeMB = 10, // usually audio larger
  });

  @override
  State<AudioUploadWidget> createState() => _AudioUploadWidgetState();
}

class _AudioUploadWidgetState extends State<AudioUploadWidget> {
  bool isDownloading = false;
  final TextEditingController urlController = TextEditingController();

  Future<void> _pickAudios(BuildContext context) async {
    final provider = Provider.of<AudioUploadProvider>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'ogg'],
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

      if ((provider.selectedAudios.length + validFiles.length) >
          widget.maxFiles) {
        final allowed = widget.maxFiles - provider.selectedAudios.length;
        if (allowed > 0) {
          provider.addAudios(validFiles.take(allowed).toList());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max ${widget.maxFiles} files allowed")),
        );
      } else {
        provider.addAudios(validFiles);
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
      Provider.of<AudioUploadProvider>(
        context,
        listen: false,
      ).addAudios([file]);
      urlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    urlController.text = "https://samplelib.com/lib/preview/mp3/sample-3s.mp3";
    return Consumer<AudioUploadProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickAudios(context),
                  icon: const Icon(Icons.library_music),
                  label: const Text("Upload From Device"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: "Paste audio URL",
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
              children: List.generate(provider.selectedAudios.length, (index) {
                final file = provider.selectedAudios[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    InkWell(
                      onTap: () => OpenFilex.open(file.path),
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.music_note,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                file.path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => provider.removeAudioAt(index),
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
