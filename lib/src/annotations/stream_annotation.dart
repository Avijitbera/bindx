import 'package:meta/meta.dart';

@immutable
class Streamed {
  final bool broadcast;
  final String? streamKey;

  const Streamed({this.broadcast = true, this.streamKey});
}

class CombinedStream {
  final List<String> dependencies;

  const CombinedStream({required this.dependencies});
}

class DebounceStream {
  final Duration duration;

  const DebounceStream({required this.duration});
}
