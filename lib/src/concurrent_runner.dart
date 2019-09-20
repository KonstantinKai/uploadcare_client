typedef Future<T> ConcurrentAction<T>();

class ConcurrentRunner<T> {
  final int _limit;
  final List<ConcurrentAction<T>> actions;

  ConcurrentRunner(
    int limit,
    this.actions,
  ) : _limit = limit > actions.length ? actions.length : limit;

  Future<List<T>> run() {
    return Future.wait(List.generate(_limit, (index) {
      final int maxInchunk = (actions.length / _limit).ceil();
      final start = index * maxInchunk;
      int end = start + maxInchunk;

      if (index == _limit - 1) end -= end - actions.length;

      return actions.sublist(start, end).fold<Future<List<T>>>(
          Future.value([]),
          (prev, next) => prev.then(
              (results) => next().then((result) => results..add(result))));
    })).then((results) => results.expand((result) => result).toList());
  }
}
