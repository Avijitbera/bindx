import 'package:meta/meta.dart';

@immutable
class Cache {
  final Duration duration;
  final String? key;
  final bool persist;
  final String? tag;
  final CacheStrategy strategy;

  const Cache({
    required this.duration,
    this.key,
    this.persist = false,
    this.tag,
    this.strategy = CacheStrategy.memory,
  });
}

enum CacheStrategy { memory, disk, memoryFirst, diskFirst }

class CacheConfig {
  final String prefix;
  final bool enabled;
  final Duration defaultDuration;

  const CacheConfig({
    required this.prefix,
    this.enabled = true,
    this.defaultDuration = const Duration(minutes: 5),
  });
}

class ReactiveCache {
  final List<String> dependencies;
  final String? key;

  const ReactiveCache({required this.dependencies, this.key});
}
