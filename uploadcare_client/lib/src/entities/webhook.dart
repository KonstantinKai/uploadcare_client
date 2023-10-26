import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum WebhookEvent {
  Uploaded('file.uploaded'),

  InfoUpdated('file.info_updated'),

  Stored('file.stored'),

  Deleted('file.deleted');

  const WebhookEvent(this._value);

  factory WebhookEvent.parse(String event) => switch (event) {
        'file.uploaded' => WebhookEvent.Uploaded,
        'file.info_updated' => WebhookEvent.InfoUpdated,
        'file.stored' => WebhookEvent.Stored,
        'file.deleted' => WebhookEvent.Deleted,
        _ => throw ArgumentError('Unknown event received: "$event"'),
      };

  final String _value;

  @override
  String toString() => _value;
}

class WebhookEntity extends Equatable {
  /// Webhook's ID
  final String id;

  /// Project ID the webhook belongs to.
  final String project;

  /// date-time when a webhook was created.
  final DateTime created;

  /// date-time when a webhook was updated.
  final DateTime updated;

  /// An event you subscribe to. Presently, only supports the `file.uploaded` event.
  final WebhookEvent event;

  /// A URL that is triggered by an event, for example, a file upload. A target URL MUST be unique for each [project] — [event] combination.
  final String targetUrl;

  /// Marks a subscription as either active or not
  final bool isActive;

  /// Webhook payload's version.
  final String version;

  /// Optional HMAC/SHA-256 secret that, if set, will be used to calculate signatures for the webhook payloads sent to the [targetUrl].
  /// Calculated signature will be sent to the [targetUrl] as a value of the `X-Uc-Signature` HTTP header. The header will have the following format: `X-Uc-Signature: v1=<HMAC-SHA256-HEX-DIGEST>`.
  /// See https://uploadcare.com/docs/security/secure-webhooks/
  final String signinSecret;

  const WebhookEntity({
    required this.id,
    required this.project,
    required this.created,
    required this.updated,
    required this.event,
    required this.targetUrl,
    required this.version,
    this.isActive = true,
    this.signinSecret = '',
  });

  factory WebhookEntity.fromJson(Map<String, dynamic> json) => WebhookEntity(
        id: json['id'].toString(),
        project: json['project'].toString(),
        created: DateTime.parse(json['created']),
        updated: DateTime.parse(json['updated']),
        event: WebhookEvent.parse(json['event']),
        targetUrl: json['target_url'],
        isActive: json['is_active'] ?? true,
        signinSecret: json['signing_secret'] ?? '',
        version: json['version'],
      );

  /// nodoc
  @protected
  @override
  List<Object?> get props => [
        id,
        project,
        created,
        updated,
        event,
        targetUrl,
        isActive,
        signinSecret,
        version,
      ];
}
