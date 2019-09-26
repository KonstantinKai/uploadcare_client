import 'package:meta/meta.dart';
import 'package:flutter_uploadcare_client/src/api_sections/api_sections.dart';
import 'package:flutter_uploadcare_client/src/options.dart';
import 'package:flutter_uploadcare_client/flutter_uploadcare_client.dart';

/// Provides centralized access to `Uploadcare API`
///
/// Feel free to use every section separately, don't forget to pass [ClientOptions] to them
class UploadcareClient {
  final ClientOptions options;
  final ApiUpload upload;
  final ApiFiles files;
  final ApiVideoEncoding videoEncoding;
  final ApiGroups groups;

  UploadcareClient({
    @required this.options,
  })  : upload = ApiUpload(options: options),
        files = ApiFiles(options: options),
        videoEncoding = ApiVideoEncoding(options: options),
        groups = ApiGroups(options: options);

  UploadcareClient.withSimpleAuth({
    @required String publicKey,
    @required String privateKey,
    @required String apiVersion,
  }) : this(
          options: ClientOptions(
            authorizationScheme: AuthSchemeSimple(
              apiVersion: apiVersion,
              publicKey: publicKey,
              privateKey: privateKey,
            ),
          ),
        );

  UploadcareClient.withRegularAuth({
    @required String publicKey,
    @required String privateKey,
    @required String apiVersion,
  }) : this(
          options: ClientOptions(
            authorizationScheme: AuthSchemeRegular(
              apiVersion: apiVersion,
              publicKey: publicKey,
              privateKey: privateKey,
            ),
          ),
        );
}
