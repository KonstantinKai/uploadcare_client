// Mocks generated by Mockito 5.0.0-nullsafety.7 from annotations
// in uploadcare_client/test/concurrent_runner_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;

import 'concurrent_runner_test.dart' as _i2;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

/// A class which mocks [TestConcurrentActions].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestConcurrentActions extends _i1.Mock
    implements _i2.TestConcurrentActions {
  MockTestConcurrentActions() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<int> action(int? number) =>
      (super.noSuchMethod(Invocation.method(#action, [number]),
          returnValue: Future.value(0)) as _i3.Future<int>);
}
