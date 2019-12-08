import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

Future<List<SharedFile>> pickFiles(BuildContext context) async {
  final file = await showModalBottomSheet<File>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Pick image from gallery'),
              onTap: () async => Navigator.pop(
                context,
                await ImagePicker.pickImage(
                  source: ImageSource.gallery,
                ),
              ),
            ),
            ListTile(
              title: Text('Pick image from camera'),
              onTap: () async => Navigator.pop(
                context,
                await ImagePicker.pickImage(
                  source: ImageSource.camera,
                ),
              ),
            ),
            ListTile(
              title: Text('Pick video from gallery'),
              onTap: () async => Navigator.pop(
                context,
                await ImagePicker.pickVideo(
                  source: ImageSource.gallery,
                ),
              ),
            ),
            ListTile(
              title: Text('Pick video from camera'),
              onTap: () async => Navigator.pop(
                context,
                await ImagePicker.pickVideo(
                  source: ImageSource.camera,
                ),
              ),
            ),
          ],
        );
      });

  if (file != null) return [SharedFile(file)];

  return const [];
}
