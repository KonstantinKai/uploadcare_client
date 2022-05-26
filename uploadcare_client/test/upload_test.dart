import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiUpload apiV05;
  late ApiUpload apiV05Signed;
  late ApiUpload apiV07;

  setUpAll(() {
    load();

    apiV05 = ApiUpload(
      options: ClientOptions(
        uploadUrl: 'http://localhost:7070/upload',
        maxIsolatePoolSize: 3,
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );

    apiV07 = ApiUpload(
      options: ClientOptions(
        uploadUrl: 'http://localhost:7070/upload',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.7',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );

    apiV05Signed = ApiUpload(
      options: ClientOptions(
        uploadUrl: 'http://localhost:7070/upload',
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
        useSignedUploads: true,
      ),
    );
  });

  test('Simple auto upload', () async {
    final internalIds = await Future.wait([
      apiV05.auto(
        UCFile(File(env['UPLOAD_BASE']!)),
        storeMode: false,
      ),
      apiV05.auto(
        env['UPLOAD_BASE']!,
        storeMode: false,
      ),
      apiV05.auto(
        env['UPLOAD_URL']!,
        storeMode: false,
      ),
    ]);

    // ignore: unnecessary_type_check
    expect(internalIds.every((id) => id is String), isTrue);
  });

  test('Simple base upload', () async {
    final id = await apiV05.base(
      UCFile(File(env['UPLOAD_BASE']!)),
      storeMode: false,
    );

    expect(id, isA<String>());
  });

  test('Simple multipart upload', () async {
    final id = await apiV05.multipart(
      UCFile(File(env['UPLOAD_MULTIPART']!)),
      storeMode: false,
    );

    expect(id, isA<String>());
  });

  test('Simple url upload', () async {
    final id = await apiV05.fromUrl(
      env['UPLOAD_URL']!,
      storeMode: false,
      checkInterval: Duration(milliseconds: 1),
    );

    expect(id, isA<String>());
  });

  test('Signed base upload', () async {
    final id = await apiV05Signed.base(
      UCFile(File(env['UPLOAD_BASE']!)),
      storeMode: false,
    );

    expect(id, isA<String>());
  });

  test('Signed multipart upload', () async {
    final id = await apiV05Signed.multipart(
      UCFile(File(env['UPLOAD_MULTIPART']!)),
      storeMode: false,
    );

    expect(id, isA<String>());
  });

  test('Signed url upload', () async {
    final id = await apiV05Signed.fromUrl(
      env['UPLOAD_URL'] ?? '',
      storeMode: false,
    );

    expect(id, isA<String>());
  });

  test('Base upload with CancelToken', () async {
    final String cancelMessage = 'some cancel message';
    final cancelToken = CancelToken(cancelMessage);
    final future = apiV05.base(
      UCFile(File(env['UPLOAD_BASE'] ?? '')),
      storeMode: false,
      cancelToken: cancelToken,
    );

    Future.delayed(
        const Duration(milliseconds: 500), () => cancelToken.cancel());

    try {
      await future;
    } on CancelUploadException catch (e) {
      expect(e, isA<CancelUploadException>());
      expect(e.message, equals(cancelMessage));
    }
  });

  test('Multipart upload with CancelToken', () async {
    final cancelToken = CancelToken();
    final future = apiV05.multipart(
      UCFile(File(env['UPLOAD_MULTIPART']!)),
      storeMode: false,
      cancelToken: cancelToken,
      onProgress: (progress) {
        if (progress.value > 0.5) {
          cancelToken.cancel();
        }
      },
    );

    try {
      await future;
    } on CancelUploadException catch (e) {
      expect(e, isA<CancelUploadException>());
    }
  });

  test('Simple multipart upload in Isolate', () async {
    final id = await apiV05.auto(
      UCFile(File(env['UPLOAD_MULTIPART']!)),
      storeMode: false,
      runInIsolate: true,
    );

    expect(id, isA<String>());
  });

  test('Multipart upload with CancelToken in Isolate', () async {
    final cancelToken = CancelToken();
    final future = apiV05.auto(
      UCFile(File(env['UPLOAD_MULTIPART']!)),
      storeMode: false,
      runInIsolate: true,
      cancelToken: cancelToken,
      onProgress: (progress) {
        if (progress.value > 0.5) {
          cancelToken.cancel();
        }
      },
    );

    try {
      await future;
    } on CancelUploadException catch (e) {
      expect(e, isA<CancelUploadException>());
    }
  });

  test(
    'Concurrent upload in Isolate',
    () async {
      final internalIds = await Future.wait([
        apiV05.auto(
          UCFile(File(env['UPLOAD_BASE']!)),
          storeMode: false,
          runInIsolate: true,
        ),
        apiV05.auto(
          env['UPLOAD_BASE']!,
          storeMode: false,
          runInIsolate: true,
        ),
        apiV05.auto(
          env['UPLOAD_MULTIPART']!,
          storeMode: false,
          runInIsolate: true,
        ),
        apiV05.auto(
          UCFile(File(env['UPLOAD_BASE']!)),
          storeMode: false,
          runInIsolate: true,
        ),
        apiV05.auto(
          env['UPLOAD_BASE']!,
          storeMode: false,
          runInIsolate: true,
        ),
        apiV05.auto(
          env['UPLOAD_MULTIPART']!,
          storeMode: false,
          runInIsolate: true,
        ),
      ]);

      expect(internalIds.length, equals(6));
      // ignore: unnecessary_type_check
      expect(internalIds.every((id) => id is String), isTrue);
    },
    timeout: Timeout.factor(2),
  );

  test('Ensure metadata version for base upload', () async {
    expect(
        () => apiV05.base(
              UCFile(File(env['UPLOAD_BASE']!)),
              storeMode: false,
              metadata: {'test': 'value'},
            ),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Ensure metadata version for multipart upload', () async {
    expect(
        () => apiV05.multipart(
              UCFile(File(env['UPLOAD_MULTIPART']!)),
              storeMode: false,
              metadata: {'test': 'value'},
            ),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Ensure metadata version for url upload', () async {
    expect(
        () => apiV05.fromUrl(
              env['UPLOAD_URL']!,
              storeMode: false,
              metadata: {'test': 'value'},
            ),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Base upload with metadata', () async {
    final id = await apiV07.base(
      UCFile(File(env['UPLOAD_BASE']!)),
      storeMode: false,
      metadata: {'test': 'value'},
    );

    expect(id, isA<String>());
  });

  test('Ensure metadata version for base upload in isolate', () async {
    expect(
        () => apiV05.auto(
              UCFile(File(env['UPLOAD_BASE']!)),
              storeMode: false,
              metadata: {'test': 'value'},
              runInIsolate: true,
            ),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Base upload with metadata in isolate', () async {
    final id = await apiV07.auto(
      UCFile(File(env['UPLOAD_BASE']!)),
      storeMode: false,
      metadata: {'test': 'value'},
      runInIsolate: true,
    );

    expect(id, isA<String>());
  });

  test('Multipart upload with metadata', () async {
    final id = await apiV07.multipart(
      UCFile(File(env['UPLOAD_MULTIPART']!)),
      storeMode: false,
      metadata: {'test': 'value'},
    );

    expect(id, isA<String>());
  });

  test('Url upload with metadata', () async {
    final id = await apiV07.fromUrl(env['UPLOAD_URL']!,
        storeMode: false,
        metadata: {'test': 'value'},
        checkURLDuplicates: false);

    expect(id, isA<String>());
  });
}
