class _IndexedResult<R> {
  final int index;
  final R value;
  _IndexedResult(this.index, this.value);
}

/// Manages a pipeline of asynchronous tasks, executing a limited number of them concurrently.
///
/// Tasks are represented by `Future<T> Function()` factories. The results are
/// collected and returned in the original order of the factories.
class PipelinedFuture<T> {
  final List<Future<T?> Function()> factories;
  final int concurrentFutures;

  PipelinedFuture(this.concurrentFutures, this.factories)
      : assert(
            concurrentFutures > 0, 'concurrentFutures must be greater than 0');

  Future<List<T?>> waitAll() async {
    final totalTasks = factories.length;
    final finalResults = List<T?>.filled(totalTasks, null);
    final resultsCompleted = List.filled(totalTasks, false);
    final activeFutures = <int, Future<_IndexedResult<T?>>>{};

    var futuresLaunched = 0;
    var futuresCollected = 0;

    while (futuresCollected < totalTasks) {
      while (futuresLaunched < totalTasks &&
          activeFutures.length < concurrentFutures) {
        final currentIndex = futuresLaunched;
        final future = factories[currentIndex]();
        activeFutures[currentIndex] =
            future.then((value) => _IndexedResult(currentIndex, value));
        futuresLaunched++;
      }

      if (activeFutures.isNotEmpty) {
        final result = await Future.any(activeFutures.values);
        finalResults[result.index] = result.value;
        resultsCompleted[result.index] = true;
        activeFutures.remove(result.index);
      }

      while (
          futuresCollected < totalTasks && resultsCompleted[futuresCollected]) {
        futuresCollected++;
      }
    }

    return finalResults;
  }
}
