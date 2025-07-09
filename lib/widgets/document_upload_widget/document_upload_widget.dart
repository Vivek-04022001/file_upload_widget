import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:upload_widget/helper/download_and_save.dart';
import 'package:upload_widget/widgets/document_upload_widget/provider.dart';

class DocumentUploadWidget extends StatefulWidget {
  final int maxFiles;
  final double maxFileSizeMB;

  const DocumentUploadWidget({
    super.key,
    this.maxFiles = 5,
    this.maxFileSizeMB = 5,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  bool isDownloading = false;
  final TextEditingController urlController = TextEditingController();

  Future<void> _pickDocs(BuildContext context) async {
    final provider = Provider.of<DocumentUploadProvider>(
      context,
      listen: false,
    );
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
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

      if ((provider.selectedDocs.length + validFiles.length) >
          widget.maxFiles) {
        final allowed = widget.maxFiles - provider.selectedDocs.length;
        if (allowed > 0) {
          provider.addDocs(validFiles.take(allowed).toList());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max ${widget.maxFiles} files allowed")),
        );
      } else {
        provider.addDocs(validFiles);
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
      Provider.of<DocumentUploadProvider>(
        context,
        listen: false,
      ).addDocs([file]);
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
    urlController.text = "https://files.testfile.org/PDF/10MB-TESTFILE.ORG.pdf";

    return Consumer<DocumentUploadProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload or Download choice
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickDocs(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload From Device"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: urlController,

                    decoration: InputDecoration(
                      hintText: "Paste file URL",
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

            // Preview section
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(provider.selectedDocs.length, (index) {
                final file = provider.selectedDocs[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    InkWell(
                      onTap: () => OpenFilex.open(file.path),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              color: Colors.blue,
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
                      onPressed: () => provider.removeDocAt(index),
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
