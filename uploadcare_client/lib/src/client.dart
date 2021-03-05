import 'api_sections/api_sections.dart';
import 'authorization/regular.dart';
import 'authorization/simple.dart';
import 'options.dart';

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
    required this.options,
  })   : upload = ApiUpload(options: options),
        files = ApiFiles(options: options),
        videoEncoding = ApiVideoEncoding(options: options),
        groups = ApiGroups(options: options);

  /// With omitted [privateKey], only upload API is available
  UploadcareClient.withSimpleAuth({
    required String publicKey,
    required String apiVersion,
    String privateKey = '',
  }) : this(
          options: ClientOptions(
            authorizationScheme: AuthSchemeSimple(
              apiVersion: apiVersion,
              publicKey: publicKey,
              privateKey: privateKey,
            ),
          ),
        );

  /// With omitted [privateKey], only upload API is available
  UploadcareClient.withRegularAuth({
    required String publicKey,
    required String apiVersion,
    String privateKey = '',
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
