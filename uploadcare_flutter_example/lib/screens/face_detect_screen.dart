import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

class FaceDetectScreen extends StatefulWidget {
  const FaceDetectScreen({
    Key? key,
    required this.uploadcareClient,
    required this.imageId,
  }) : super(key: key);

  final UploadcareClient uploadcareClient;
  final String imageId;

  @override
  _FaceDetectScreenState createState() => _FaceDetectScreenState();
}

class _FaceDetectScreenState extends State<FaceDetectScreen> {
  late Future<FacesEntity> _future;
  late GlobalKey _key;

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
        title: const Text('Face detection screen'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<FacesEntity> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.hasFaces) {
            return const Center(
              child: Text('No faces has been detected'),
            );
          }

          RenderBox? renderBox = context.findRenderObject() as RenderBox?;

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
                ...snapshot.data!
                    .getRelativeFaces(
                  Size(
                    renderBox!.size.width,
                    renderBox.size.width /
                        snapshot.data!.originalSize.toSize().aspectRatio,
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
