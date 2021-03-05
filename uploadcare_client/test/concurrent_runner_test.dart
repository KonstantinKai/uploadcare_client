import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:uploadcare_client/src/concurrent_runner.dart';

class _TestConcurrentActions {
  Future<int> action(int number) => Future.value(number);
}

class _TestConcurrentActionsMock extends Mock
    implements _TestConcurrentActions {
  @override
  Future<int> action(int? number) =>
      super.noSuchMethod(Invocation.method(#action, [number]));
}

void main() {
  late List<ConcurrentAction<int?>> actions;
  late _TestConcurrentActionsMock testObject;

  setUpAll(() {
    testObject = _TestConcurrentActionsMock();
    actions = List.generate(
      10,
      (index) => () {
        when(testObject.action(index)).thenAnswer((_) =>
            Future.delayed(Duration(milliseconds: index * 10), () => index));

        return testObject.action(index);
      },
    );
  });

  setUp(() {
    reset(testObject);
  });

  test('Test #1', () async {
    final results = await ConcurrentRunner(4, actions).run();

    expect(
      verify(testObject.action(captureAny)).captured,
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );

    expect(results, equals(List.generate(10, (index) => index)));
  });

  test('Test #2', () async {
    await ConcurrentRunner(2, actions).run();

    expect(
      verify(testObject.action(captureAny)).captured,
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });

  test('Test #3', () async {
    await ConcurrentRunner(1, actions).run();

    expect(
      verify(testObject.action(captureAny)).captured,
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });

  test('Test #4', () async {
    await ConcurrentRunner(10, actions).run();

    expect(
      verify(testObject.action(captureAny)).captured,
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });

  test('Test #5', () async {
    await ConcurrentRunner(20, actions).run();

    expect(
      verify(testObject.action(captureAny)).captured,
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });
}
