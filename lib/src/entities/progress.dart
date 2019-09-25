import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// An object that represents progress data
class ProgressEntity extends Equatable {
  /// Total size in bytes
  final int total;

  /// Uploaded size in bytes
  final int uploaded;

  const ProgressEntity(this.uploaded, this.total);

  factory ProgressEntity.fromJson(Map<String, dynamic> json) =>
      ProgressEntity(json['done'], json['total']);

  /// returns 0..1 double
  double get value => double.parse((uploaded / total).toStringAsFixed(2));

  ProgressEntity copyWith({int uploaded, int total}) =>
      ProgressEntity(uploaded ?? this.uploaded, total ?? this.total);

  /// @nodoc
  @protected
  @override
  List get props => [total, uploaded];
}
