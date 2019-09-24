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
  final Stream<VideoEncodingJobEntity> encoding$;
  final Stream<ProgressEntity> progress$;

  const _Item({
    this.fileInfo,
    this.encoding$,
    this.progress$,
  });
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<List<_Item>> _controller;
  UploadcareClient _client;

  @override
  void initState() {
    super.initState();

    _client = UploadcareClient.withSimpleAuth(
      publicKey: DotEnv().env['UPLOADCARE_PUBLIC_KEY'],
      privateKey: DotEnv().env['UPLOADCARE_PRIVATE_KEY'],
      apiVersion: 'v0.5',
    );

    _controller = StreamController.broadcast();

    WidgetsBinding.instance.addPostFrameCallback((_) => _client.files
        .list(
            limit: 500,
            ordering: FilesOrdering(
              FilesFilterValue.DatetimeUploaded,
              direction: OrderDirection.Desc,
            ))
        .then((value) => _controller
            .add(value.results.map((item) => _Item(fileInfo: item)).toList())));
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
              client: _client,
              progress$: files[index].progress$,
              encoding$: files[index].encoding$,
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
              setState(() {});
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
    final StreamController<ProgressEntity> progress =
        StreamController.broadcast();
    Stream<VideoEncodingJobEntity> encoding$;

    _controller.add((await _controller.stream.last)
      ..insert(
          0,
          _Item(
            progress$: progress.stream,
          )));

    final fileId = await _client.upload.auto(
      file,
      storeMode: false,
      onProgress: (value) => progress.add(value),
    );

    progress.close();

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
        encoding$ =
            _client.videoEncoding.statusAsStream(result.results.first.token);
      } else {
        encoding$ = Stream.error(Exception(result.problems.values.first));
      }
    }

    _controller.add((await _controller.stream.last)
      ..replaceRange(0, 1, [
        _Item(
          encoding$: encoding$,
          fileInfo: fileInfo,
        )
      ]));
  }
}

class MediaListItem extends StatefulWidget {
  MediaListItem({
    Key key,
    this.fileInfo,
    this.client,
    this.progress$,
    this.encoding$,
  }) : super(key: key);

  final FileInfoEntity fileInfo;
  final UploadcareClient client;
  final Stream<ProgressEntity> progress$;
  final Stream<VideoEncodingJobEntity> encoding$;

  _MediaListItemState createState() => _MediaListItemState();
}

class _MediaListItemState extends State<MediaListItem> {
  FileInfoEntity _fileInfo;
  Stream<VideoEncodingJobEntity> get _encoding$ => widget.encoding$;

  Stream<ProgressEntity> get _progress => widget.progress$;

  UploadcareClient get _client => widget.client;

  bool get _isUploaded => _fileInfo != null;

  @override
  initState() {
    super.initState();

    _fileInfo = widget.fileInfo;
  }

  Widget _buildEncoding() => StreamBuilder(
        stream: _encoding$,
        builder: (context, AsyncSnapshot<VideoEncodingJobEntity> snapshot) {
          if (snapshot.hasError)
            return Text(
              (snapshot.error as dynamic).message,
              style: TextStyle(
                color: Colors.redAccent,
              ),
            );
          if (!snapshot.hasData) return Text('getting status...');
          if (snapshot.data.status == VideoEncodingJobStatusValue.Finished)
            return Text(_fileInfo.filename);

          return Text('encoding...');
        },
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!_isUploaded)
            Center(
              child: StreamBuilder(
                stream: _progress,
                initialData: null,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return LinearProgressIndicator(
                    value: snapshot?.data?.value,
                  );
                },
              ),
            ),
          if (_isUploaded)
            ListTile(
              contentPadding: const EdgeInsets.all(10.0),
              leading: _fileInfo.isImage
                  ? Image(
                      height: 58,
                      width: 58,
                      fit: BoxFit.contain,
                      image: UploadcareImageProvider(
                        _fileInfo.id,
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
              title: _isUploaded && _encoding$ == null
                  ? Text(_fileInfo?.filename ?? 'preparing...')
                  : _buildEncoding(),
            ),
        ],
      ),
    );
  }
}
