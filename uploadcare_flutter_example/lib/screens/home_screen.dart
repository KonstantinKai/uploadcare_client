import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:uploadcare_flutter/uploadcare_flutter.dart';
import '../picker_stub.dart'
    if (dart.library.html) '../picker_web.dart'
    if (dart.library.io) '../picker_io.dart';
import 'files_screen.dart';
import 'upload_screen.dart';
import 'project_info_screen.dart';

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
}
