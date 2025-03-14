// ignore_for_file: deprecated_member_use_from_same_package

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
    expect(file1.appData, isNull);

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
    expect(file2.appData, isNull);
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
    expect(file2.appData, isNull);

    expect(
        () => apiV07.file('3c269810-c17b-4e2c-92b6-25622464d866',
            includeRecognitionInfo: true),
        throwsA(TypeMatcher<AssertionError>()));
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

  test('Get file with AWSRecognition application data', () async {
    final file = await apiV07.file('file-with-aws-recognition',
        include: const FilesIncludeFields.withAppData());

    expect(file.appData, isNotNull);
    expect(file.appData!.awsRecognition, isA<AWSRekognitionAddonResult>());
  });

  test('Get file with AWSRecognitionModeration application data', () async {
    final file = await apiV07.file('file-with-aws-recognition-moderation',
        include: const FilesIncludeFields.withAppData());

    expect(file.appData, isNotNull);
    expect(file.appData!.awsRecognitionModeration,
        isA<AWSRekognitionModerationAddonResult>());
  });

  test('Get file with ClamAV application data', () async {
    final file = await apiV07.file('file-with-clamav',
        include: const FilesIncludeFields.withAppData());

    expect(file.appData, isNotNull);
    expect(file.appData!.clamAV, isA<ClamAVAddonResult>());
  });

  test('Get file with RemoveBg application data', () async {
    final file = await apiV07.file('file-with-removebg',
        include: const FilesIncludeFields.withAppData());

    expect(file.appData, isNotNull);
    expect(file.appData!.removeBg, isA<RemoveBgAddonResult>());
  });

  test('Get file application data', () async {
    final result = await apiV07.getApplicationData('file-id');

    expect(result, isMap);
    expect(result, contains('uc_clamav_virus_scan'));

    expect(() => apiV06.getApplicationData('file-id'),
        throwsA(TypeMatcher<AssertionError>()));
  }, skip: 'Moved to addons section');

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
  }, skip: 'Moved to addons section');

  test('Copy file to local storage', () async {
    final result1 = await apiV06.copyToLocalStorage('file-id');
    final result2 = await apiV07.copyToLocalStorage('file-id');

    expect(result1, isA<FileInfoEntity>());
    expect(result2, isA<FileInfoEntity>());
  });

  test('Copy file to local storage should throw errors', () async {
    expect(() => apiV05.copyToLocalStorage('file-id'),
        throwsA(TypeMatcher<AssertionError>()));
    expect(
        () => apiV06
            .copyToLocalStorage('file-id', metadata: const {'key1': 'value1'}),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Copy file to remote storage', () async {
    final result1 =
        await apiV06.copyToRemoteStorage(fileId: 'file-id', target: 'remote');
    final result2 =
        await apiV07.copyToRemoteStorage(fileId: 'file-id', target: 'remote');

    expect(result1,
        equals('s3://mybucket/03ccf9ab-f266-43fb-973d-a6529c55c2ae/image.png'));
    expect(result2,
        equals('s3://mybucket/03ccf9ab-f266-43fb-973d-a6529c55c2ae/image.png'));

    expect(FilesPatternValue.Default.toString(), equals('\${default}'));
  });

  test('Copy file to remote storage should throw errors', () async {
    expect(
        () => apiV05.copyToRemoteStorage(fileId: 'file-id', target: 'remote'),
        throwsA(TypeMatcher<AssertionError>()));
  });
}
