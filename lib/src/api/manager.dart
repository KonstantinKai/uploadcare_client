import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/file_info.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/options.dart';

class UploadcareApiManager
    with UploadcareOptionsShortcutsMixin, UploadcareTransportHelperMixin {
  UploadcareApiManager({
    @required this.options,
  }) : assert(options != null);

  final UploadcareOptions options;

  Future<UploadcareFileInfo> fileInfo(String fileId) async =>
      UploadcareFileInfo.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri(
              '$requestUrl/files/$fileId/',
            ),
          ).send(),
        ),
      );

  Future<void> removeFiles(List<String> fileIds) async {
    if (fileIds.length > 100)
      throw RangeError('Can be removed up to 100 files per request');

    final request = createRequest(
      'DELETE',
      buildUri('$requestUrl/files/storage/'),
    )..body = jsonEncode(fileIds);

    await resolveStreamedResponse(request.send());
  }
}
