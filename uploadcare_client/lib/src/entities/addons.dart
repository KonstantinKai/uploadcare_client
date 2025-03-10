import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Defines the status of an Add-On execution.
/// In most cases, once the status changes to [AddonExecutionStatusValue.Done], Application Data of the file
/// that had been specified as a target, will contain the result of the execution.
enum AddonExecutionStatusValue {
  InProgress,

  Error,

  Done,

  Unknown;

  factory AddonExecutionStatusValue.parse(String? status) => switch (status) {
        'in_progress' => AddonExecutionStatusValue.InProgress,
        'error' => AddonExecutionStatusValue.Error,
        'done' => AddonExecutionStatusValue.Done,
        'unknown' => AddonExecutionStatusValue.Unknown,
        _ => throw ArgumentError('Unknown status: "$status"'),
      };
}

class AddonExecutionStatus<T> extends Equatable {
  final AddonExecutionStatusValue status;

  final T? result;

  const AddonExecutionStatus({
    required this.status,
    this.result,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [status, result];
}

enum RemoveBgTypeLevelValue {
  /// No classification (foreground_type won't bet set in the application data)
  None('none'),

  /// Use coarse classification classes: [person, product, animal, car, other]
  One('1'),

  /// Use more specific classification classes: [person, product, animal, car, car_interior, car_part, transportation, graphics, other]
  Two('2'),

  /// Always use the latest classification classes available
  Latest('latest');

  const RemoveBgTypeLevelValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

enum RemoveBgTypeValue {
  Auto('auto'),

  Person('person'),

  Product('product'),

  Car('car');

  const RemoveBgTypeValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

enum RemoveBgChannelsValue {
  Rgba('rgba'),

  Aplha('alpha');

  const RemoveBgChannelsValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

class AddonResultInfo extends Equatable {
  final String version;

  final DateTime created;

  final DateTime updated;

  const AddonResultInfo({
    required this.version,
    required this.created,
    required this.updated,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        version,
        created,
        updated,
      ];

  factory AddonResultInfo.fromJson(Map<String, dynamic> json) =>
      AddonResultInfo(
        version: json['version'],
        created: DateTime.parse(json['datetime_created']),
        updated: DateTime.parse(json['datetime_updated']),
      );
}

class RemoveBgAddonResult extends Equatable {
  final AddonResultInfo info;

  final String foregroundType;

  const RemoveBgAddonResult({
    required this.info,
    required this.foregroundType,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        info,
        foregroundType,
      ];
}

class ClamAVAddonResult extends Equatable {
  final AddonResultInfo info;

  final bool infected;

  final String infectedWith;

  const ClamAVAddonResult({
    required this.info,
    required this.infected,
    required this.infectedWith,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        info,
        infected,
        infectedWith,
      ];
}

class AWSRekognitionAddonResult extends Equatable {
  final AddonResultInfo info;

  final String labelModelVersion;

  final List<AWSRecognitionLabel> labels;

  const AWSRekognitionAddonResult({
    required this.info,
    required this.labelModelVersion,
    required this.labels,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        info,
        labelModelVersion,
        labels,
      ];
}

class AWSRecognitionLabel extends Equatable {
  final num confidence;

  final String name;

  final List<AWSRecognitionInstance> instances;

  final List<String> parents;

  const AWSRecognitionLabel({
    required this.confidence,
    required this.name,
    required this.instances,
    required this.parents,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        confidence,
        name,
        instances,
        parents,
      ];
}

class AWSRecognitionInstance extends Equatable {
  final ASWRecognitionBoundingBox boundingBox;

  final num confidence;

  const AWSRecognitionInstance({
    required this.boundingBox,
    required this.confidence,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        boundingBox,
        confidence,
      ];

  @override
  String toString() {
    return 'L: ${boundingBox.left};T: ${boundingBox.top}; W: ${boundingBox.width}; H: ${boundingBox.height};';
  }
}

/// See https://docs.aws.amazon.com/rekognition/latest/dg/images-displaying-bounding-boxes.html
class ASWRecognitionBoundingBox extends Equatable {
  final double top;

  final double left;

  final double width;

  final double height;

  const ASWRecognitionBoundingBox({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  /// nodoc
  @protected
  @override
  List<Object?> get props => [
        top,
        left,
        width,
        height,
      ];
}

/// See https://uploadcare.com/docs/unsafe-content/?utm_source=subscribers&utm_medium=email&utm_campaign=product_newsletter_mar&utm_content=image_content_moderation
class AWSRekognitionModerationAddonResult extends Equatable {
  final AddonResultInfo info;

  final String modelVersion;

  final List<AWSRecognitionModerationLabel> labels;

  const AWSRekognitionModerationAddonResult({
    required this.info,
    required this.modelVersion,
    required this.labels,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        info,
        modelVersion,
        labels,
      ];
}

/// See https://docs.aws.amazon.com/rekognition/latest/dg/moderation.html
class AWSRecognitionModerationLabel extends Equatable {
  final num confidence;

  final String name;

  final String parentName;

  const AWSRecognitionModerationLabel({
    required this.confidence,
    required this.name,
    required this.parentName,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        confidence,
        name,
        parentName,
      ];
}
