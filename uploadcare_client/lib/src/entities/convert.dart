import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

typedef ConvertResultCreator<T> = T Function(Map<String, dynamic> data);

enum ConvertJobStatusValue {
  /// A source file is being prepared for conversion
  Pending,

  /// Conversion is in progress
  Processing,

  /// Failed to convert the source, see error for details.
  Failed,

  /// The conversion is finished
  Finished,

  /// The conversion was canceled
  Canceled;

  factory ConvertJobStatusValue.parse(String? status) => switch (status) {
        'pending' => ConvertJobStatusValue.Pending,
        'processing' => ConvertJobStatusValue.Processing,
        'failed' => ConvertJobStatusValue.Failed,
        'finished' => ConvertJobStatusValue.Finished,
        'canceled' => ConvertJobStatusValue.Canceled,
        'cancelled' => ConvertJobStatusValue.Canceled,
        _ => throw ArgumentError('Unknown status: "$status"'),
      };
}

/// Provides status data for converting job
class ConvertJobEntity<E extends ConvertResultEntity> extends Equatable {
  /// Encoding job status
  final ConvertJobStatusValue status;
  final E? result;

  /// Holds a processing error message
  final String? errorMessage;

  const ConvertJobEntity({
    required this.status,
    this.errorMessage,
    this.result,
  });

  factory ConvertJobEntity.fromJson(
    Map<String, dynamic> json,
    ConvertResultCreator<E> resultFactory,
  ) {
    final status = ConvertJobStatusValue.parse(json['status']);

    return ConvertJobEntity(
      status: status,
      errorMessage: json['error'],
      result: status == ConvertJobStatusValue.Finished
          ? resultFactory(json['result'])
          : null,
    );
  }

  /// @nodoc
  @protected
  @override
  List get props => [status, errorMessage, result];
}

/// Provides response data from convert job
class ConvertEntity<E extends ConvertResultEntity> extends Equatable {
  final List<E> results;

  /// Problems related to your processing job, if any.
  final Map<String, String> problems;

  const ConvertEntity({
    required this.results,
    this.problems = const {},
  });

  factory ConvertEntity.fromJson(
    Map<String, dynamic> json,
    ConvertResultCreator<E> resultFactory,
  ) =>
      ConvertEntity(
        problems: (json['problems'] as Map).cast<String, String>(),
        results: (json['result'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(resultFactory)
            .toList(),
      );

  /// @nodoc
  @protected
  @override
  List get props => [results, problems];
}

/// Provides converting result data
abstract class ConvertResultEntity extends Equatable {
  /// A UUID of your processed video file.
  final String processedFileId;

  /// Input file identifier including transformations, if present.
  final String? originSourceLocation;

  /// A processing job token that can be used to get a job status
  final int? token;

  const ConvertResultEntity({
    required this.processedFileId,
    this.originSourceLocation,
    this.token,
  });

  /// @nodoc
  @protected
  @override
  List get props => [
        originSourceLocation,
        processedFileId,
        token,
      ];
}
