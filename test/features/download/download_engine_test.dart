import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/download/data/download_engine.dart';

void main() {
  test('a single-subscription stream can be listened to again after the first listener leaves', () async {
    final source = StreamController<int>();
    final stream = reusableStream(source.stream);

    final first = <int>[];
    final firstSubscription = stream.listen(first.add);
    source.add(1);
    await Future<void>.delayed(Duration.zero);
    await firstSubscription.cancel();

    final second = <int>[];
    final secondSubscription = stream.listen(second.add);
    source.add(2);
    await Future<void>.delayed(Duration.zero);
    await secondSubscription.cancel();

    expect(first, [1]);
    expect(second, [2]);
    await source.close();
  });

  test('without it the second listen fails', () async {
    final source = StreamController<int>();
    await source.stream.listen((_) {}).cancel();
    expect(() => source.stream.listen((_) {}), throwsStateError);
  });
}
