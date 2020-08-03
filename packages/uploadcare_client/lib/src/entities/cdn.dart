import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class CndEntity extends Equatable {
  final String id;

  const CndEntity(this.id) : assert(id != null, 'id should be provided');

  /// @nodoc
  @protected
  @override
  List get props => [id];
}
