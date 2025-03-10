import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiAddons api;

  setUpAll(() {
    api = ApiAddons(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.7',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
  });

  test('Execute AWS recognition task', () async {
    final response = await api.executeAWSRekognition('file-id');

    expect(response, equals('8db3c8b4-2dea-4146-bcdb-63387e2b33c1'));
  });

  test('Get status about AWS recognition', () async {
    final response1 = await api.checkAWSRekognitionExecutionStatus('done');
    expect(response1, isA<AddonExecutionStatus>());
    expect(response1.status, equals(AddonExecutionStatusValue.InProgress));
    final response2 = await api.checkAWSRekognitionExecutionStatus('done');
    expect(response2.status, equals(AddonExecutionStatusValue.Done));

    await api.checkAWSRekognitionExecutionStatus('unknown');
    final response3 = await api.checkAWSRekognitionExecutionStatus('unknown');
    expect(response3.status, equals(AddonExecutionStatusValue.Unknown));

    await api.checkAWSRekognitionExecutionStatus('error');
    final response4 = await api.checkAWSRekognitionExecutionStatus('error');
    expect(response4.status, equals(AddonExecutionStatusValue.Error));
  });

  test('Get status about AWS recognition as Stream with done', () {
    final stream = api.checkTaskExecutionStatusAsStream(
        requestId: 'done',
        task: api.checkAWSRekognitionExecutionStatus,
        checkInterval: Duration(milliseconds: 10));

    expect(
        stream,
        emitsInOrder([
          isA<AddonExecutionStatus>(),
          isA<AddonExecutionStatus>().having((p0) => p0.status, 'status',
              equals(AddonExecutionStatusValue.Done)),
          emitsDone,
        ]));
  });

  test('Execute AWS recognition moderation task', () async {
    final response = await api.executeAWSRekognitionModeration('file-id');

    expect(response, equals('8db3c8b4-2dea-4146-bcdb-63387e2b33c1'));
  });

  test('Get status about AWS recognition moderation', () async {
    final response1 =
        await api.checkAWSRekognitionModerationExecutionStatus('done');
    expect(response1, isA<AddonExecutionStatus>());
    expect(response1.status, equals(AddonExecutionStatusValue.InProgress));
    final response2 =
        await api.checkAWSRekognitionModerationExecutionStatus('done');
    expect(response2.status, equals(AddonExecutionStatusValue.Done));

    await api.checkAWSRekognitionModerationExecutionStatus('unknown');
    final response3 =
        await api.checkAWSRekognitionModerationExecutionStatus('unknown');
    expect(response3.status, equals(AddonExecutionStatusValue.Unknown));

    await api.checkAWSRekognitionModerationExecutionStatus('error');
    final response4 =
        await api.checkAWSRekognitionModerationExecutionStatus('error');
    expect(response4.status, equals(AddonExecutionStatusValue.Error));
  });

  test('Get status about AWS recognition moderation as Stream with done', () {
    final stream = api.checkTaskExecutionStatusAsStream(
        requestId: 'done',
        task: api.checkAWSRekognitionModerationExecutionStatus,
        checkInterval: Duration(milliseconds: 10));

    expect(
        stream,
        emitsInOrder([
          isA<AddonExecutionStatus>(),
          isA<AddonExecutionStatus>().having((p0) => p0.status, 'status',
              equals(AddonExecutionStatusValue.Done)),
          emitsDone,
        ]));
  });

  test('Execute ClamAV task', () async {
    final response1 = await api.executeClamAV('file-id');
    expect(response1, equals('8db3c8b4-2dea-4146-bcdb-63387e2b33c1'));

    final response2 = await api.executeClamAV('file-id', purgeInfected: true);
    expect(response2, equals('8db3c8b4-2dea-4146-bcdb-63387e2b33c1'));
  });

  test('Get status about ClamAV', () async {
    final response1 = await api.checkClamAVExecutionStatus('done');
    expect(response1, isA<AddonExecutionStatus>());
    expect(response1.status, equals(AddonExecutionStatusValue.InProgress));
    final response2 = await api.checkClamAVExecutionStatus('done');
    expect(response2.status, equals(AddonExecutionStatusValue.Done));

    await api.checkClamAVExecutionStatus('unknown');
    final response3 = await api.checkClamAVExecutionStatus('unknown');
    expect(response3.status, equals(AddonExecutionStatusValue.Unknown));

    await api.checkClamAVExecutionStatus('error');
    final response4 = await api.checkClamAVExecutionStatus('error');
    expect(response4.status, equals(AddonExecutionStatusValue.Error));
  });

  test('Get status about ClamAV as Stream with done', () {
    final stream = api.checkTaskExecutionStatusAsStream(
        requestId: 'done',
        task: api.checkClamAVExecutionStatus,
        checkInterval: Duration(milliseconds: 10));

    expect(
        stream,
        emitsInOrder([
          isA<AddonExecutionStatus>(),
          isA<AddonExecutionStatus>().having((p0) => p0.status, 'status',
              equals(AddonExecutionStatusValue.Done)),
          emitsDone,
        ]));
  });

  test('Execute RemoveBg task', () async {
    final response1 = await api.executeRemoveBg('file-id');
    expect(response1, equals('8db3c8b4-2dea-4146-bcdb-63387e2b33c1'));

    final response2 = await api.executeRemoveBg(
      'file-id',
      crop: true,
      cropMargin: '80%',
      scale: '20%',
      addShadow: false,
      channels: RemoveBgChannelsValue.Rgba,
      typeLevel: RemoveBgTypeLevelValue.Latest,
      type: RemoveBgTypeValue.Auto,
      position: '1',
      roi: 'roi',
      semitransparency: false,
    );
    expect(response2, equals('8db3c8b4-2dea-4146-bcdb-63387e2b33c1'));
  });

  test('Get status about RemoveBg', () async {
    final response1 = await api.checkRemoveBgExecutionStatus('done');
    expect(response1, isA<AddonExecutionStatus>());
    expect(response1.status, equals(AddonExecutionStatusValue.InProgress));
    final response2 = await api.checkRemoveBgExecutionStatus('done');
    expect(response2.status, equals(AddonExecutionStatusValue.Done));

    await api.checkRemoveBgExecutionStatus('unknown');
    final response3 = await api.checkRemoveBgExecutionStatus('unknown');
    expect(response3.status, equals(AddonExecutionStatusValue.Unknown));

    await api.checkRemoveBgExecutionStatus('error');
    final response4 = await api.checkRemoveBgExecutionStatus('error');
    expect(response4.status, equals(AddonExecutionStatusValue.Error));
  });

  test('Get status about RemoveBg as Stream with done', () {
    final stream = api.checkTaskExecutionStatusAsStream(
        requestId: 'done',
        task: api.checkRemoveBgExecutionStatus,
        checkInterval: Duration(milliseconds: 10));

    expect(
        stream,
        emitsInOrder([
          isA<AddonExecutionStatus>(),
          isA<AddonExecutionStatus>().having((p0) => p0.status, 'status',
              equals(AddonExecutionStatusValue.Done)),
          emitsDone,
        ]));
  });

  test('Should throws error if API version less than 0.7', () async {
    final apiV06 = ApiAddons(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.6',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );

    expect(() => apiV06.executeAWSRekognition('file'),
        throwsA(TypeMatcher<AssertionError>()));
    expect(() => apiV06.checkAWSRekognitionExecutionStatus('request'),
        throwsA(TypeMatcher<AssertionError>()));

    expect(() => apiV06.executeAWSRekognitionModeration('file'),
        throwsA(TypeMatcher<AssertionError>()));
    expect(() => apiV06.checkAWSRekognitionModerationExecutionStatus('request'),
        throwsA(TypeMatcher<AssertionError>()));

    expect(() => apiV06.executeClamAV('file'),
        throwsA(TypeMatcher<AssertionError>()));
    expect(() => apiV06.checkClamAVExecutionStatus('request'),
        throwsA(TypeMatcher<AssertionError>()));

    expect(() => apiV06.executeRemoveBg('file'),
        throwsA(TypeMatcher<AssertionError>()));
    expect(() => apiV06.checkRemoveBgExecutionStatus('request'),
        throwsA(TypeMatcher<AssertionError>()));
  });
}
