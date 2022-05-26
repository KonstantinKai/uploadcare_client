import 'dart:async';

import 'package:meta/meta.dart';

import '../entities/convert.dart';
import '../transformations/base.dart';

@internal
mixin ConvertMixin<E extends ConvertResultEntity, T extends Transformation> {
  @visibleForOverriding
  Future<ConvertEntity<E>> process(
    Map<String, List<T>> transformers, {
    bool? storeMode,
  });

  @visibleForOverriding
  Future<ConvertJobEntity<E>> status(int token);

  Future<void> _statusTimerCallback(
    int token,
    Duration checkInterval,
    StreamController<ConvertJobEntity<E>> controller,
  ) async {
    final response = await status(token);

    controller.add(response);

    if ([ConvertJobStatusValue.Processing, ConvertJobStatusValue.Pending]
        .contains(response.status)) {
      Timer(checkInterval,
          () => _statusTimerCallback(token, checkInterval, controller));
      return;
    }

    controller.close();
  }

  /// Returns processing job as `Stream`
  ///
  /// [token] from [ConvertResultEntity.token]
  /// [checkInterval] check status interval
  Stream<ConvertJobEntity<E>> statusAsStream(
    int token, {
    Duration checkInterval = const Duration(seconds: 5),
  }) {
    final StreamController<ConvertJobEntity<E>> controller =
        StreamController.broadcast();

    Timer(checkInterval,
        () => _statusTimerCallback(token, checkInterval, controller));

    return controller.stream;
  }
}
