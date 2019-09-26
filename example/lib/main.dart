import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() async {
  await DotEnv().load('.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter uploadcare client example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter uploadcare client example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _Item {
  final FileInfoEntity fileInfo;
  final VideoEncodingJobEntity encoding;
  final ProgressEntity progress;

  const _Item({
    this.fileInfo,
    this.encoding,
    this.progress,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Item &&
          runtimeType == other.runtimeType &&
          fileInfo == other.fileInfo &&
          encoding == other.encoding &&
          progress == other.progress;

  @override
  int get hashCode => fileInfo.hashCode ^ encoding.hashCode ^ progress.hashCode;
}

class _MyHomePageState extends State<MyHomePage> {
  List<_Item> _files;
  StreamController<List<_Item>> _controller;
  UploadcareClient _client;

  @override
  void initState() {
    super.initState();

    _files = [];

    _client = UploadcareClient.withSimpleAuth(
      publicKey: DotEnv().env['UPLOADCARE_PUBLIC_KEY'],
      privateKey: DotEnv().env['UPLOADCARE_PRIVATE_KEY'],
      apiVersion: 'v0.5',
    );

    _controller = StreamController.broadcast();

    WidgetsBinding.instance.addPostFrameCallback((_) => _client.files
            .list(
                limit: 500,
                stored: false,
                removed: false,
                ordering: FilesOrdering(
                  FilesFilterValue.DatetimeUploaded,
                  direction: OrderDirection.Desc,
                ))
            .then((value) {
          _files.addAll(
              value.results.map((item) => _Item(fileInfo: item)).toList());

          _controller.add(_files);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<List<_Item>> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          final files = snapshot.data;

          return ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              height: 5,
            ),
            itemCount: files.length,
            itemBuilder: (context, index) => MediaListItem(
              fileInfo: files[index].fileInfo,
              progress: files[index].progress,
              encoding: files[index].encoding,
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.image),
            onPressed: () async {
              final file =
                  await ImagePicker.pickImage(source: ImageSource.gallery);

              if (file == null) return;

              _upload(file);
            },
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.camera),
            onPressed: () async {
              final file =
                  await ImagePicker.pickVideo(source: ImageSource.camera);

              if (file == null) return;

              _upload(file);
            },
          ),
        ],
      ),
    );
  }

  Future _upload(File file) async {
    _files.insert(
      0,
      _Item(
        progress: ProgressEntity(0, await file.length()),
      ),
    );

    _controller.add(_files);

    final fileId = await _client.upload.auto(
      file,
      storeMode: false,
      onProgress: (value) {
        _files[0] = _Item(progress: value);
        _controller.add(_files);
      },
    );

    final fileInfo = await _client.files.file(fileId);

    if (!fileInfo.isImage) {
      final videoTransformations = [
        CutTransformation(const Duration(seconds: 0),
            length: const Duration(seconds: 10)),
        VideoThumbsGenerateTransformation(5),
      ];
      final result =
          await _client.videoEncoding.process({fileId: videoTransformations});

      if (result.problems.isEmpty) {
        final stream =
            _client.videoEncoding.statusAsStream(result.results.first.token);
        await for (VideoEncodingJobEntity job in stream) {
          _files[0] = _Item(
            fileInfo: fileInfo,
            encoding: job,
          );
          _controller.add(_files);
        }
      } else {
        _files[0] = _Item(
          fileInfo: fileInfo,
          encoding: VideoEncodingJobEntity(
            errorMessage: result.problems.values.first,
            status: VideoEncodingJobStatusValue.Failed,
          ),
        );
        _controller.add(_files);
      }
    }

    _files[0] = _Item(
      fileInfo: fileInfo,
    );

    _controller.add(_files);
  }
}

class MediaListItem extends StatelessWidget {
  MediaListItem({
    Key key,
    this.fileInfo,
    this.progress,
    this.encoding,
  }) : super(key: key);

  final FileInfoEntity fileInfo;
  final ProgressEntity progress;
  final VideoEncodingJobEntity encoding;

  bool get _isUploaded => fileInfo != null;

  Widget _buildEncoding() {
    if (encoding.status == VideoEncodingJobStatusValue.Failed)
      return Text(
        encoding.errorMessage,
        style: TextStyle(
          color: Colors.redAccent,
        ),
      );
    if (encoding.status == VideoEncodingJobStatusValue.Processing ||
        encoding.status == VideoEncodingJobStatusValue.Pending)
      return Text('encoding...');
    if (encoding.status == VideoEncodingJobStatusValue.Finished)
      return Text(fileInfo.filename);

    return Text('getting status...');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!_isUploaded)
            Center(
              child: LinearProgressIndicator(
                value: progress?.value == 1 ? null : progress?.value ?? null,
              ),
            ),
          if (_isUploaded)
            ListTile(
              contentPadding: const EdgeInsets.all(10.0),
              leading: fileInfo.isImage
                  ? Image(
                      height: 58,
                      width: 58,
                      fit: BoxFit.contain,
                      image: UploadcareImageProvider(
                        fileInfo.id,
                        transformations: [
                          BlurTransformation(50),
                          GrayscaleTransformation(),
                          InvertTransformation(),
                          ImageResizeTransformation(Size.square(58))
                        ],
                      ),
                    )
                  : Container(
                      height: 58,
                      width: 58,
                      child: Center(
                        child: Icon(Icons.video_library),
                      ),
                    ),
              title: _isUploaded && encoding == null
                  ? Text(fileInfo?.filename ?? 'preparing...')
                  : _buildEncoding(),
            ),
        ],
      ),
    );
  }
}
