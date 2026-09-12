import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension CacheForExtension on Ref {
  /// Caches the provider state for [duration] before allowing it to be disposed.
  /// If the provider is listened to again before the duration expires,
  /// the disposal timer is cancelled and the cached data remains available.
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;

    onCancel(() {
      timer = Timer(duration, () {
        link.close();
      });
    });

    onResume(() {
      timer?.cancel();
    });

    onDispose(() {
      timer?.cancel();
    });
  }
}
