import 'package:uploadcare_client/src/constants.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';

class CdnFile extends CndEntity {
  final String cdnUrl;

  CdnFile(
    String id, {
    this.cdnUrl = kDefaultCdnEndpoint,
  })  : assert(id != null),
        super(id);

  Uri get uri => Uri.parse(cdnUrl).replace(path: '/$id/');

  String get url => uri.toString();
}
