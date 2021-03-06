import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class CndEntity extends Equatable {
  final String id;

  const CndEntity(this.id);

  /// @nodoc
  @protected
  @override
  List get props => [id];
}
