import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uploadcare_client/uploadcare_client.dart';
import 'picker_stub.dart'
    if (dart.library.html) 'picker_web.dart'
    if (dart.library.io) 'picker_io.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  UploadcareClient _uploadcareClient;

  @override
  void initState() {
    super.initState();
    _uploadcareClient = UploadcareClient.withSimpleAuth(
      publicKey: DotEnv().env['UPLOADCARE_PUBLIC_KEY'],
      privateKey: DotEnv().env['UPLOADCARE_PRIVATE_KEY'],
      apiVersion: 'v0.5',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Upload'),
              onPressed: _onUpload,
            ),
            const SizedBox(
              height: 20,
            ),
            RaisedButton(
              child: Text('Files'),
              onPressed: _onFiles,
            ),
          ],
        ),
      ),
    );
  }

  Future _onUpload() async {
    final files = await pickFiles(context);

    if (files.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => UploadScreen(
              file: files.first,
              uploadcareClient: _uploadcareClient,
            ),
          ));
    }
  }

  void _onFiles() => Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FilesScreen(
          uploadcareClient: _uploadcareClient,
        ),
      ));
}

class UploadScreen extends StatefulWidget {
  UploadScreen({
    Key key,
    this.file,
    this.uploadcareClient,
  }) : super(key: key);

  final SharedFile file;
  final UploadcareClient uploadcareClient;

  _UploadScreenState createState() => _UploadScreenState();
}

enum UploadState {
  Uploading,
  Error,
  Uploaded,
  Canceled,
}

class _UploadScreenState extends State<UploadScreen> {
  CancelToken _cancelToken;
  StreamController<ProgressEntity> _progressController;
  UploadState _uploadState;
  String _fileId;
  FileInfoEntity _fileInfoEntity;
  String _cancelMessage;

  @override
  void initState() {
    super.initState();

    _uploadState = UploadState.Uploading;
    _cancelToken = CancelToken('canceled by user');
    _progressController = StreamController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _fileId = await widget.uploadcareClient.upload.auto(
          widget.file,
          cancelToken: _cancelToken,
          storeMode: false,
          onProgress: (progress) => _progressController.add(progress),
        );
        _fileInfoEntity = await widget.uploadcareClient.files.file(_fileId);
        _uploadState = UploadState.Uploaded;
      } on CancelUploadException catch (e) {
        _uploadState = UploadState.Canceled;
        _cancelMessage = e.message;
      } catch (e) {
        _uploadState = UploadState.Error;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _progressController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload screen'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      if (_uploadState == UploadState.Uploading)
                        StreamBuilder(
                          stream: _progressController.stream,
                          builder: (context,
                              AsyncSnapshot<ProgressEntity> snapshot) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                LinearProgressIndicator(
                                  value: snapshot.hasData
                                      ? snapshot.data.value
                                      : null,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (snapshot.hasData)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          'uploaded: ${snapshot.data.uploaded}'),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text('total: ${snapshot.data.total}'),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                      if (_uploadState == UploadState.Uploaded &&
                          _fileInfoEntity.isImage)
                        Image(
                          image: UploadcareImageProvider(_fileId),
                          fit: BoxFit.contain,
                        ),
                      if (_uploadState == UploadState.Canceled)
                        Text(
                          _cancelMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(widget.file.name),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text('Cancel'),
                onPressed: _uploadState == UploadState.Uploading &&
                        !_cancelToken.isCanceled
                    ? _cancelToken.cancel
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilesScreen extends StatefulWidget {
  FilesScreen({
    Key key,
    this.uploadcareClient,
  }) : super(key: key);

  final UploadcareClient uploadcareClient;

  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  StreamController<List<FileInfoEntity>> _filesController;
  int _total;
  int _limit;

  @override
  void initState() {
    super.initState();

    _filesController = StreamController();
    _limit = 200;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final files = await widget.uploadcareClient.files.list(
        offset: 0,
        limit: _limit,
        stored: null,
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
        title: Text('Files screen'),
        actions: <Widget>[
          if (_total != null)
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
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          final files = snapshot.data;

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];

              return ListTile(
                title: Text('Filename: ${file.filename}'),
                subtitle: Text('Type: ${file.isImage ? 'image' : 'video'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (file.isImage)
                      IconButton(
                        icon: Icon(Icons.face),
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
                    IconButton(
                      icon: Icon(
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

class FaceDetectScreen extends StatefulWidget {
  FaceDetectScreen({
    Key key,
    this.uploadcareClient,
    this.imageId,
  }) : super(key: key);

  final UploadcareClient uploadcareClient;
  final String imageId;

  @override
  _FaceDetectScreenState createState() => _FaceDetectScreenState();
}

class _FaceDetectScreenState extends State<FaceDetectScreen> {
  Future<FacesEntity> _future;
  GlobalKey _key;

  @override
  void initState() {
    super.initState();

    _key = GlobalKey();
    _future = widget.uploadcareClient.files.getFacesEntity(widget.imageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face detection screen'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<FacesEntity> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          if (!snapshot.data.hasFaces)
            return Center(
              child: Text('No faces has been detected'),
            );

          RenderBox renderBox = context.findRenderObject();

          return FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image(
                    key: _key,
                    image: UploadcareImageProvider(widget.imageId),
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
                ...snapshot.data
                    .getRelativeFaces(
                  Size(
                    renderBox.size.width,
                    renderBox.size.width /
                        snapshot.data.originalSize.aspectRatio,
                  ),
                )
                    .map((face) {
                  return Positioned(
                    top: face.top,
                    left: face.left,
                    child: Container(
                      width: face.size.width,
                      height: face.size.height,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        border: Border.all(color: Colors.white54, width: 1.0),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
