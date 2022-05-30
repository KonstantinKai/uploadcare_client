import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiFiles apiV05;
  late ApiFiles apiV06;
  late ApiFiles apiV07;

  setUpAll(() {
    apiV05 = ApiFiles(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        cdnUrl: 'http://localhost:7070/cdn',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
    apiV06 = ApiFiles(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        cdnUrl: 'http://localhost:7070/cdn',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.6',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
    apiV07 = ApiFiles(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        cdnUrl: 'http://localhost:7070/cdn',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.7',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
  });

  test('Get files v0.5', () async {
    final response = await apiV05.list();

    expect(response, TypeMatcher<ListEntity<FileInfoEntity>>());
    expect(response.totals, isNull);

    expect(() => apiV05.list(includeRecognitionInfo: true),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Get files v0.6', () async {
    final response = await apiV06.list();

    expect(response, TypeMatcher<ListEntity<FileInfoEntity>>());
    expect(response.totals, isNotNull);
    expect(response.totals!.removed, greaterThan(0));
    expect(response.totals!.stored, greaterThan(0));
    expect(response.totals!.unstored, greaterThan(0));
  });

  test('Get files v0.7', () async {
    final response = await apiV07.list();

    expect(response, TypeMatcher<ListEntity<FileInfoEntity>>());
    expect(response.totals, isNotNull);
    expect(response.totals!.removed, greaterThan(0));
    expect(response.totals!.stored, greaterThan(0));
    expect(response.totals!.unstored, greaterThan(0));
  });

  test('Get file info v0.5', () async {
    final file1 = await apiV05.file('3c269810-c17b-4e2c-92b6-25622464d866');

    expect(file1, TypeMatcher<FileInfoEntity>());
    expect(file1.imageInfo, isA<ImageInfo>());
    expect(file1.isImage, isTrue);

    expect(
        () => apiV05.file('3c269810-c17b-4e2c-92b6-25622464d866',
            includeRecognitionInfo: true),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Get file info v0.6', () async {
    final file1 = await apiV06.file('3c269810-c17b-4e2c-92b6-25622464d866');

    expect(file1, TypeMatcher<FileInfoEntity>());
    expect(file1.imageInfo, isA<ImageInfo>());
    expect(file1.recognitionInfo, isNotNull);
    expect(file1.isImage, isTrue);

    final file2 = await apiV06.file('7ed2aed0-0482-4c13-921b-0557b193edc2');

    expect(file2, TypeMatcher<FileInfoEntity>());
    expect(file2.videoInfo, isA<VideoInfo>());
    expect(file2.isImage, isFalse);
    expect(file2.recognitionInfo, isNull);
  });

  test('Get file info v0.7', () async {
    final file1 = await apiV07.file('3c269810-c17b-4e2c-92b6-25622464d866');

    expect(file1, TypeMatcher<FileInfoEntity>());
    expect(file1.imageInfo, isA<ImageInfo>());
    expect(file1.isImage, isTrue);
    expect(file1.metadata, isNotNull);

    final file2 = await apiV07.file('7ed2aed0-0482-4c13-921b-0557b193edc2');

    expect(file2, TypeMatcher<FileInfoEntity>());
    expect(file2.videoInfo, isA<VideoInfo>());
    expect(file2.isImage, isFalse);
    expect(file2.metadata, isNotNull);
  });

  test('Remove files', () async {
    await apiV07.remove(['7ed2aed0-0482-4c13-921b-0557b193edc2']);
  });

  test('Detect faces with FacesEntity', () async {
    final entity =
        await apiV07.getFacesEntity('5128ec65-9957-47b8-a6ad-4c2f172ef660');

    expect(entity, TypeMatcher<FacesEntity>());
    expect(entity.hasFaces, equals(true));
  });

  test('Get file metadata', () async {
    final metadata = await apiV07.getFileMetadata('file-id');

    expect(() => apiV06.getFileMetadata('file-id'),
        throwsA(TypeMatcher<AssertionError>()));

    expect(metadata, isMap);
    expect(metadata['key1'], equals('value1'));
    expect(metadata['fileId'], equals('file-id'));
  });

  test('Get file metadata value', () async {
    final metadata = await apiV07.getFileMetadataValue('file-id', 'meta-key');

    expect(() => apiV06.getFileMetadataValue('file-id', 'meta-key'),
        throwsA(TypeMatcher<AssertionError>()));

    expect(metadata, equals('value1_file-id_meta-key'));
  });

  test('Update file metadata value', () async {
    final metadata = await apiV07.updateFileMetadataValue(
        'file-id', 'meta-key', 'new-value');

    expect(
        () =>
            apiV06.updateFileMetadataValue('file-id', 'meta-key', 'new-value'),
        throwsA(TypeMatcher<AssertionError>()));

    expect(metadata, equals('new-value_file-id_meta-key'));
  });

  test('Delete file metadata value', () async {
    await apiV07.deleteFileMetadataValue('file-id', 'meta-key');

    expect(() => apiV06.deleteFileMetadataValue('file-id', 'meta-key'),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Get file application data', () async {
    final result = await apiV07.getApplicationData('file-id');

    expect(result, isMap);
    expect(result, contains('uc_clamav_virus_scan'));

    expect(() => apiV06.getApplicationData('file-id'),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Get file application data by appName', () async {
    final result = await apiV07.getApplicationDataByAppName(
        'file-id', 'uc_clamav_virus_scan');

    expect(result, isMap);
    expect(result, contains('data'));
    expect(result, contains('datetime_created'));
    expect(result, contains('datetime_updated'));

    expect(
        () => apiV06.getApplicationDataByAppName(
            'file-id', 'uc_clamav_virus_scan'),
        throwsA(TypeMatcher<AssertionError>()));
  });
}
