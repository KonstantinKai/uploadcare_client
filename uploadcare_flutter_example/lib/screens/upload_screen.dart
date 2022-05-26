// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({
    Key? key,
    required this.file,
    required this.uploadcareClient,
  }) : super(key: key);

  final UCFile file;
  final UploadcareClient uploadcareClient;

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

enum UploadState {
  Uploading,
  Error,
  Uploaded,
  Canceled,
}

class _UploadScreenState extends State<UploadScreen> {
  late final CancelToken _cancelToken;
  late StreamController<ProgressEntity> _progressController;
  late UploadState _uploadState;
  late String _fileId;
  late FileInfoEntity _fileInfoEntity;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _uploadState = UploadState.Uploading;
    _cancelToken = CancelToken('canceled by user');
    _progressController = StreamController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<String, String>? metadata;

      if (widget.uploadcareClient.options.apiVersion >= 0.7) {
        metadata = {
          'metakey': 'metavalue',
        };
      }

      try {
        _fileId = await widget.uploadcareClient.upload.auto(
          widget.file,
          cancelToken: _cancelToken,
          storeMode: false,
          onProgress: (progress) => _progressController.add(progress),
          metadata: metadata,
        );
        _fileInfoEntity = await widget.uploadcareClient.files.file(_fileId);
        _uploadState = UploadState.Uploaded;
      } on CancelUploadException catch (e) {
        _uploadState = UploadState.Canceled;
        _errorMessage = e.message;
      } catch (e) {
        _uploadState = UploadState.Error;
        _errorMessage = e.toString();
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
        title: const Text('Upload screen'),
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
                                      ? snapshot.data!.value
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
                                          'uploaded: ${snapshot.data!.uploaded}'),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text('total: ${snapshot.data!.total}'),
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
                      if ([
                        UploadState.Canceled,
                        UploadState.Error,
                      ].contains(_uploadState))
                        Text(
                          _errorMessage ?? '',
                          style: const TextStyle(color: Colors.red),
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
              ElevatedButton(
                child: const Text('Cancel'),
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
