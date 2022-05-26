import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  final FileInfoEntity file;

  @override
  Widget build(BuildContext context) {
    Widget content = Container();

    if (file.isImage) {
      content = Image(
        image: UploadcareImageProvider(file.id),
        fit: BoxFit.contain,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('File preview'),
      ),
      body: Center(
        child: content,
      ),
    );
  }
}
