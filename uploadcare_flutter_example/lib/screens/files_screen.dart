import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

import 'face_detect_screen.dart';
import 'file_info_screen.dart';
import 'preview_screen.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({
    Key? key,
    required this.uploadcareClient,
  }) : super(key: key);

  final UploadcareClient uploadcareClient;

  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final int _limit = 100;
  late int _total;
  late final StreamController<List<FileInfoEntity>> _filesController;

  @override
  void initState() {
    super.initState();

    _filesController = StreamController();
    _total = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final files = await widget.uploadcareClient.files.list(
        offset: 0,
        limit: _limit,
        stored: false,
        ordering: const FilesOrdering(
          FilesFilterValue.DatetimeUploaded,
          direction: OrderDirection.Desc,
        ),
      );

      setState(() {
        _total = files.total;
      });

      _filesController.add(files.results);
    });
  }

  @override
  void dispose() {
    _filesController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files screen'),
        actions: <Widget>[
          if (_total > 0)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Center(child: Text('Total: $_total')),
            ),
        ],
      ),
      body: StreamBuilder(
        stream: _filesController.stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<FileInfoEntity>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final files = snapshot.data!;

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FileInfoScreen(file: file),
                  ),
                ),
                title: Text('Filename: ${file.filename}'),
                subtitle: Text(
                    'Type: ${file.isImage ? 'image' : file.isVideo ? 'video' : file.mimeType}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (file.isImage) ...[
                      IconButton(
                        splashRadius: 25,
                        icon: const Icon(Icons.remove_red_eye_rounded),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => PreviewScreen(file: file),
                          ),
                        ),
                      ),
                      IconButton(
                        splashRadius: 25,
                        icon: const Icon(Icons.face),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => FaceDetectScreen(
                              uploadcareClient: widget.uploadcareClient,
                              imageId: file.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                    IconButton(
                      splashRadius: 25,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        await widget.uploadcareClient.files.remove([file.id]);
                        setState(() {
                          _total--;
                        });
                        _filesController.add(files..removeAt(index));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
