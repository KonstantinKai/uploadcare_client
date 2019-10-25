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

    if (file != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => UploadScreen(
              file: file,
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

  final File file;
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
                      Text(widget.file.path),
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
        stored: false,
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
                trailing: IconButton(
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
              );
            },
          );
        },
      ),
    );
  }
}
