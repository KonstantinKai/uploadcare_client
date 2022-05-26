import '../entities/webhook.dart';
import '../mixins/options_shortcuts_mixin.dart';
import '../mixins/transport_helper_mixin.dart';
import '../options.dart';

/// **Since v0.6**
///
/// See https://uploadcare.com/api-refs/rest-api/v0.6.0/#tag/Webhook
class ApiWebhooks with OptionsShortcutMixin, TransportHelperMixin {
  @override
  final ClientOptions options;

  ApiWebhooks({
    required this.options,
  });

  /// List of project webhooks
  Future<List<WebhookEntity>> list() async {
    _ensureRightVersionForWebhooks();

    final response = await resolveStreamedResponse(
      createRequest('GET', buildUri('$apiUrl/webhooks/')).send(),
    );

    return (response as List).map((e) => WebhookEntity.fromJson(e)).toList();
  }

  /// Create and subscribe to a webhook. You can use webhooks to receive notifications about your uploads.
  /// For instance, once a file gets uploaded to your project, we can notify you by sending a message to a target URL
  Future<WebhookEntity> create({
    required String targetUrl,
    required WebhookEvent event,
    bool? isActive,
    String? signingSecret,
    String? version,
  }) async {
    _ensureRightVersionForWebhooks();

    final request = createMultipartRequest(
      'POST',
      buildUri('$apiUrl/webhooks/'),
    )..fields.addAll({
        'target_url': targetUrl,
        'event': event.toString(),
        if (isActive != null) 'is_active': isActive.toString(),
        if (signingSecret != null) 'signing_secret': signingSecret,
        if (version != null) 'version': version,
      });

    final response = await resolveStreamedResponse(request.send());
    return WebhookEntity.fromJson(response as Map<String, dynamic>);
  }

  /// Update webhook attributes
  Future<WebhookEntity> update({
    required String hookId,
    String? targetUrl,
    WebhookEvent? event,
    bool? isActive,
    String? signingSecret,
  }) async {
    _ensureRightVersionForWebhooks();

    final request = createMultipartRequest(
      'PUT',
      buildUri('$apiUrl/webhooks/$hookId/'),
    )..fields.addAll({
        if (targetUrl != null) 'target_url': targetUrl,
        if (event != null) 'event': event.toString(),
        if (isActive != null) 'is_active': isActive.toString(),
        if (signingSecret != null) 'signing_secret': signingSecret,
      });

    final response = await resolveStreamedResponse(request.send());
    return WebhookEntity.fromJson(response as Map<String, dynamic>);
  }

  /// Unsubscribe and delete a webhook
  Future<void> delete(String targetUrl) async {
    _ensureRightVersionForWebhooks();

    final request = createMultipartRequest(
      'DELETE',
      buildUri('$apiUrl/webhooks/unsubscribe/'),
    )..fields.addAll({
        'target_url': targetUrl,
      });

    await resolveStreamedResponse(request.send());
  }

  void _ensureRightVersionForWebhooks() {
    ensureRightVersion(0.6, 'Webhooks API');
  }
}
