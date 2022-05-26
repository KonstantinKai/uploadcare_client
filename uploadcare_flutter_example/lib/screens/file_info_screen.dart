import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FileInfoScreen extends StatelessWidget {
  const FileInfoScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  final FileInfoEntity file;

  Future<void> _onTryToDownload() async {
    final cdnFile = CdnFile(file.id)
      ..transform(const InlineTransformation(false));
    final url = cdnFile.url;

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File info'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File info: "${file.filename}"'),
              const SizedBox(width: 20),
              ElevatedButton(
                child: const Text('Try to download'),
                onPressed: _onTryToDownload,
              ),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: IntrinsicColumnWidth(flex: 1),
                  1: IntrinsicColumnWidth(flex: 3),
                },
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('uuid'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(file.id),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('mimeType'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(file.mimeType),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('size'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(file.size.toString()),
                      ),
                    ],
                  ),
                  if (file.datetimeUploaded != null)
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('datetimeUploaded'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.datetimeUploaded.toString()),
                        ),
                      ],
                    ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('isStored'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(file.isStored.toString()),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('isReady'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(file.isReady.toString()),
                      ),
                    ],
                  ),
                ],
              ),
              if (file.metadata != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('File metadata:'),
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: IntrinsicColumnWidth(flex: 1),
                    1: IntrinsicColumnWidth(flex: 3),
                  },
                  children: [
                    for (MapEntry entry in file.metadata!.entries)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(entry.key),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(entry.value),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
              if (file.isImage) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Image metadata:'),
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: IntrinsicColumnWidth(flex: 1),
                    1: IntrinsicColumnWidth(flex: 3),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('size'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.imageInfo!.size.toString()),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('format'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.imageInfo!.format),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('sequence'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.imageInfo!.sequence.toString()),
                        ),
                      ],
                    ),
                    if (file.imageInfo!.colorMode != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('colorMode'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(file.imageInfo!.colorMode.toString()),
                          ),
                        ],
                      ),
                    if (file.imageInfo!.datetimeOriginal != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('datetimeOriginal'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                file.imageInfo!.datetimeOriginal.toString()),
                          ),
                        ],
                      ),
                    if (file.imageInfo!.dpi != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('dpi'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(file.imageInfo!.dpi.toString()),
                          ),
                        ],
                      ),
                    if (file.imageInfo!.orientation != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('orientation'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(file.imageInfo!.orientation.toString()),
                          ),
                        ],
                      ),
                    if (file.imageInfo!.geoLocation != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('geoLocation'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(file.imageInfo!.geoLocation.toString()),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
              if (file.isVideo) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Video metadata:'),
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: IntrinsicColumnWidth(flex: 1),
                    1: IntrinsicColumnWidth(flex: 3),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('format'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.videoInfo!.format),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('duration'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.videoInfo!.duration.toString()),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('bitrate'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.videoInfo!.bitrate.toString()),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('videostream.size'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.videoInfo!.video.size.toString()),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('videostream.codec'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.videoInfo!.video.codec.toString()),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('videostream.frameRate'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text(file.videoInfo!.video.frameRate.toString()),
                        ),
                      ],
                    ),
                    if (file.videoInfo!.audio?.channels != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('audiostream.channels'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                file.videoInfo!.audio!.channels!.toString()),
                          ),
                        ],
                      ),
                    if (file.videoInfo!.audio?.bitrate != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('audiostream.bitrate'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                file.videoInfo!.audio!.bitrate!.toString()),
                          ),
                        ],
                      ),
                    if (file.videoInfo!.audio?.codec != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('audiostream.codec'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(file.videoInfo!.audio!.codec!),
                          ),
                        ],
                      ),
                    if (file.videoInfo!.audio?.sampleRate != null)
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('audiostream.sampleRate'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                file.videoInfo!.audio!.sampleRate!.toString()),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
