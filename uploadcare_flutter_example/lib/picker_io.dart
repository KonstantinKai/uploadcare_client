import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

Future<List<UCFile>> pickFiles(BuildContext context) async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    final result = await FilePicker.platform.pickFiles();

    if (result is FilePickerResult) {
      return [UCFile.fromUri(Uri.file(result.files.single.path!))];
    }

    return const [];
  }

  final ImagePicker picker = ImagePicker();
  final file = await showModalBottomSheet<PickedFile>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Pick image from gallery'),
              onTap: () async => Navigator.pop(
                context,
                await picker.getImage(
                  source: ImageSource.gallery,
                ),
              ),
            ),
            ListTile(
              title: const Text('Pick image from camera'),
              onTap: () async => Navigator.pop(
                context,
                await picker.getImage(
                  source: ImageSource.camera,
                ),
              ),
            ),
            ListTile(
              title: const Text('Pick video from gallery'),
              onTap: () async => Navigator.pop(
                context,
                await picker.getVideo(
                  source: ImageSource.gallery,
                ),
              ),
            ),
            ListTile(
              title: const Text('Pick video from camera'),
              onTap: () async => Navigator.pop(
                context,
                await picker.getVideo(
                  source: ImageSource.camera,
                ),
              ),
            ),
          ],
        );
      });

  if (file != null) return [UCFile.fromUri(Uri.file(file.path))];

  return const [];
}
