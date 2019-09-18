import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/api/upload.dart';
import 'package:uploadcare_client/src/options.dart';

class UploadcareClient {
  UploadcareClient({
    @required this.options,
  }) : upload = UploadcareApiUpload(options: options);

  final UploadcareOptions options;
  final UploadcareApiUpload upload;
}
