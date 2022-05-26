import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiWebhooks api;

  setUpAll(() {
    api = ApiWebhooks(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.6',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
  });

  test('Get list of webhooks', () async {
    final list = await api.list();

    expect(list, TypeMatcher<List<WebhookEntity>>());
  });

  test('Create webhook', () async {
    final webhook = await api.create(
        targetUrl: 'http://testwebhook.com', event: WebhookEvent.Uploaded);

    expect(webhook, TypeMatcher<WebhookEntity>());
  });

  test('Update webhook', () async {
    final webhook = await api.update(
      hookId: '1',
      targetUrl: 'http://testwebhook.com',
      event: WebhookEvent.Uploaded,
    );

    expect(webhook, TypeMatcher<WebhookEntity>());
  });

  test('Delete webhook', () async {
    await api.delete('http://testwebhook.com');

    try {
      await api.delete('');
    } on ClientException catch (e) {
      expect(e.toString(), contains('"{"detail":"`target_url` is missing"}"'));
    }
  });
}
