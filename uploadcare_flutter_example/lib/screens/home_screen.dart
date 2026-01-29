import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:uploadcare_flutter/uploadcare_flutter.dart';
import '../picker_stub.dart'
    if (dart.library.html) '../picker_web.dart'
    if (dart.library.io) '../picker_io.dart';
import 'files_screen.dart';
import 'upload_screen.dart';
import 'project_info_screen.dart';
import 'transformations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final UploadcareClient _apiV05;
  late final UploadcareClient _apiV06;
  late final UploadcareClient _apiV07;

  @override
  void initState() {
    super.initState();
    _apiV05 = UploadcareClient.withSimpleAuth(
      publicKey: dot_env.env['UPLOADCARE_PUBLIC_KEY']!,
      privateKey: dot_env.env['UPLOADCARE_PRIVATE_KEY']!,
      apiVersion: 'v0.5',
    );
    _apiV06 = UploadcareClient.withSimpleAuth(
      publicKey: dot_env.env['UPLOADCARE_PUBLIC_KEY']!,
      privateKey: dot_env.env['UPLOADCARE_PRIVATE_KEY']!,
      apiVersion: 'v0.6',
    );
    _apiV07 = UploadcareClient.withRegularAuth(
      publicKey: dot_env.env['UPLOADCARE_PUBLIC_KEY']!,
      privateKey: dot_env.env['UPLOADCARE_PRIVATE_KEY']!,
      apiVersion: 'v0.7',
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
            ElevatedButton(
              child: const Text('Project info'),
              onPressed: () => _onProjectInfo(_apiV05),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text('Upload with v0.5'),
              onPressed: () => _onUpload(_apiV05),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Upload with v0.6'),
              onPressed: () => _onUpload(_apiV06),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Upload with v0.7'),
              onPressed: () => _onUpload(_apiV07),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Files with v0.5'),
              onPressed: () => _onFiles(_apiV05),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Files with v0.6'),
              onPressed: () => _onFiles(_apiV06),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Files with v0.7'),
              onPressed: () => _onFiles(_apiV07),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text('Transformations'),
              onPressed: () => _onTransformations(_apiV06),
            ),
          ],
        ),
      ),
    );
  }

  Future _onProjectInfo(UploadcareClient client) async {
    final info = await client.project.info();

    Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => ProjectInfoScreen(
            project: info,
          ),
        ));
  }

  Future _onUpload(UploadcareClient client) async {
    final files = await pickFiles(context);

    if (files.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => UploadScreen(
              file: files.first,
              uploadcareClient: client,
            ),
          ));
    }
  }

  void _onFiles(UploadcareClient client) => Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FilesScreen(
          uploadcareClient: client,
        ),
      ));

  Future _onTransformations(UploadcareClient client) async {
    final files = await client.files.list(
      limit: 100,
      stored: false,
      ordering: const FilesOrdering(
        FilesFilterValue.DatetimeUploaded,
        direction: OrderDirection.Desc,
      ),
    );

    final imageFiles = files.results.where((f) => f.isImage).toList();

    if (imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images found. Upload an image first.')),
      );
      return;
    }

    final selectedFile = await showDialog<FileInfoEntity>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select an image'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: imageFiles.length,
            itemBuilder: (context, index) {
              final file = imageFiles[index];
              return ListTile(
                title: Text(file.filename),
                subtitle: Text(file.id),
                onTap: () => Navigator.pop(context, file),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => TransformationsScreen(
            file: selectedFile,
          ),
        ),
      );
    }
  }
}
