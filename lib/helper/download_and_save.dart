import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<File> downloadAndSaveFile(String url, String filename) async {
  final dir = await getTemporaryDirectory();
  final filePath = "${dir.path}/$filename";

  final response = await Dio().download(
    url,
    filePath,
    options: Options(responseType: ResponseType.bytes),
  );

  return File(filePath);
}
