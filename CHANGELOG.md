# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- [ ] Code generation with `build_runner` integration
- [ ] Time-travel debugging
- [ ] Redux DevTools integration
- [ ] State persistence strategies
- [ ] More middleware examples

## [0.0.1] - 2025-12-20

### Added

#### Core Features
- **BindXStore**: Reactive state container with automatic change notification
- **BindxRegistry**: Global store registry for dependency injection
- **BindXMixin**: Mixin for adding middleware support to stores

#### Annotations
- `@Cache`: Cache method results with configurable duration and persistence
  - Memory and disk caching strategies
  - Cache invalidation by tag
  - Reactive cache dependencies
- `@Concurrent`: Control concurrent method execution
  - Debounce and throttle support
  - Queue management with priority
  - Maximum concurrency limits
- `@Streamed`: Convert properties to reactive streams
  - Broadcast and single-subscription streams
  - Stream key management
- `@Validate`: Validate method parameters
  - Built-in validators (email, url, notEmpty, etc.)
  - Custom validation logic
- `@Mutex`: Mutual exclusion locks for thread safety
- `@Retry`: Automatic retry with configurable attempts and delay
- `@Timeout`: Method execution timeouts

#### Widgets
- `BindXProvider`: Provide stores to widget tree
- `BindXConsumer`: Consume and rebuild on store changes
- `MultiBindXProvider`: Provide multiple stores
- `BindXMultiBuilder`: Build from multiple stores
- `BindXMultiConsumer`: Consume multiple stores

#### Extensions
- **Stream Extensions** (`BindXStreamExtensions`):
  - `debounce()`: Debounce stream emissions
  - `throttle()`: Throttle stream emissions
  - `distinct()`: Filter distinct values
  - `switchMap()`: Switch to new stream
  - `mergeMap()`: Merge concurrent streams
  - `combineWith()`: Combine streams
  - `bufferTime()`: Buffer values over time
  - `sampleTime()`: Sample at intervals
  - `cacheLatest()`: Cache and replay latest value
  - `retryWithBackoff()`: Retry with exponential backoff
  - `tap()`: Execute side effects
  - `whereNotNull()`: Filter null values
  - `mapNotNull()`: Map non-null values
  - `groupBy()`: Group values by key
  - `shareReplay()`: Share subscription with replay

- **Stream Utilities** (`BindXStreamUtils`):
  - `firstValue`: Get first value as Future
  - `lastValue`: Get last value as Future
  - `containsWhere()`: Check if contains value
  - `firstWhereOrNull()`: Find first matching value
  - `toListAsync()`: Convert to List
  - `toMap()`: Convert to Map
  - `forEachAsync()`: Execute for each value

- **Stream Combinators** (`BindXStreamCombinators`):
  - `merge()`: Merge multiple streams
  - `concat()`: Concatenate streams
  - `combineLatest()`: Combine latest values
  - `race()`: First stream to emit wins

- **Future Extensions** (`BindXFutureExtensions`):
  - `timeoutAfter()`: Timeout with fallback
  - `map()`: Map result value
  - `mapOrElse()`: Map with error handling
  - `filter()`: Filter result
  - `recover()`: Recover from errors
  - `tap()`: Execute side effects
  - `combineWith()`: Combine futures
  - `asStream()`: Convert to stream
  - `delayBy()`: Delay result
  - `asCancellable()`: Make cancellable
  - `asResult()`: Convert to Result type
  - `match()`: Pattern match on result
  - `getOrNull()`: Get value or null
  - `flatMap()`: Flat map transformation
  - `validate()`: Validate result

- **Future Combinators** (`BindXFutureCombinators`):
  - `waitAll()`: Wait for all futures
  - `waitAllInOrder()`: Wait preserving order
  - `race()`: First to complete
  - `sequence()`: Execute sequentially
  - `withConcurrency()`: Limited concurrency
  - `mapAll()`: Map and wait for all

- **Future Utilities** (`BindXFutureUtils`):
  - `orDefault()`: Default value on timeout
  - `safe()`: Never throws (returns null)
  - `withCancellationToken()`: Cancellable with token

#### Utilities
- **Result**: Type-safe result handling (Success/Failure)
- **CancellableFuture**: Futures that can be cancelled
- **CancellationToken**: Token for cancelling operations
- **BindXAsync**: Async utilities (periodic, delayed, executeWithRetry)

#### Middleware
- `Middleware<T>`: Base middleware interface
- `LoggingMiddleware`: Log all state changes
- `PersistenceMiddleware`: Persist state to storage

#### Caching
- `CacheEngine`: In-memory and disk caching
- `DiskStorage`: Persistent storage with SharedPreferences

#### Concurrency
- `TaskManager`: Manage concurrent task execution
- `TaskQueue`: Priority-based task queuing

#### DevTools
- `BindXDevTools`: Developer tools integration
- `BindXDevToolsOverlay`: Debug overlay widget
- Store inspection and time-travel debugging UI

### Dependencies
- `flutter`: >=1.17.0
- `meta`: ^1.16.0
- `analyzer`: ^8.4.1
- `build`: ^3.0.0
- `source_gen`: ^4.1.1
- `crypto`: ^3.0.7
- `dartz`: ^0.10.1
- `path_provider`: ^2.1.5
- `shared_preferences`: ^2.5.3

### Documentation
- Comprehensive README with examples
- API documentation for all public classes
- Code examples for common use cases
- Contributing guidelines

## [0.0.1-dev] - 2025-12-15

### Added
- Initial project structure
- Basic store implementation
- Annotation definitions
- Core widget implementations

## [0.0.2] - 2026-02-11

### Added
- Updated pubspec.yaml
- Implement `BindxStore` lifecycle methods for locking, caching, and streaming
- Remove unused imports and memory cache


---

## Legend

- `Added`: New features
- `Changed`: Changes to existing functionality
- `Deprecated`: Soon-to-be removed features
- `Removed`: Removed features
- `Fixed`: Bug fixes
- `Security`: Security improvements

[Unreleased]: https://github.com/yourusername/bindx/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/yourusername/bindx/releases/tag/v0.0.1
[0.0.1-dev]: https://github.com/yourusername/bindx/releases/tag/v0.0.1-dev
