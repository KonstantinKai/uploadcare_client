import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    Key? key,
    required this.fileId,
  }) : super(key: key);

  final String fileId;

  @override
  Widget build(BuildContext context) {
    Widget content = Container();

    content = Image(
      image: UploadcareImageProvider(fileId),
      fit: BoxFit.contain,
    );

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
