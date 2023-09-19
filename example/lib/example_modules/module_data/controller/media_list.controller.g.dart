// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_list.controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaListControllerHash() =>
    r'b68e32c3cdb07798c1c4558a104f40d9652cedbd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MediaListController
    extends BuildlessAutoDisposeAsyncNotifier<List<FileProxy>> {
  late final String bucketId;

  Future<List<FileProxy>> build(
    String bucketId,
  );
}

/// See also [MediaListController].
@ProviderFor(MediaListController)
const mediaListControllerProvider = MediaListControllerFamily();

/// See also [MediaListController].
class MediaListControllerFamily extends Family<AsyncValue<List<FileProxy>>> {
  /// See also [MediaListController].
  const MediaListControllerFamily();

  /// See also [MediaListController].
  MediaListControllerProvider call(
    String bucketId,
  ) {
    return MediaListControllerProvider(
      bucketId,
    );
  }

  @override
  MediaListControllerProvider getProviderOverride(
    covariant MediaListControllerProvider provider,
  ) {
    return call(
      provider.bucketId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mediaListControllerProvider';
}

/// See also [MediaListController].
class MediaListControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MediaListController, List<FileProxy>> {
  /// See also [MediaListController].
  MediaListControllerProvider(
    String bucketId,
  ) : this._internal(
          () => MediaListController()..bucketId = bucketId,
          from: mediaListControllerProvider,
          name: r'mediaListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mediaListControllerHash,
          dependencies: MediaListControllerFamily._dependencies,
          allTransitiveDependencies:
              MediaListControllerFamily._allTransitiveDependencies,
          bucketId: bucketId,
        );

  MediaListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bucketId,
  }) : super.internal();

  final String bucketId;

  @override
  Future<List<FileProxy>> runNotifierBuild(
    covariant MediaListController notifier,
  ) {
    return notifier.build(
      bucketId,
    );
  }

  @override
  Override overrideWith(MediaListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MediaListControllerProvider._internal(
        () => create()..bucketId = bucketId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bucketId: bucketId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MediaListController, List<FileProxy>>
      createElement() {
    return _MediaListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaListControllerProvider && other.bucketId == bucketId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bucketId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MediaListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<FileProxy>> {
  /// The parameter `bucketId` of this provider.
  String get bucketId;
}

class _MediaListControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MediaListController,
        List<FileProxy>> with MediaListControllerRef {
  _MediaListControllerProviderElement(super.provider);

  @override
  String get bucketId => (origin as MediaListControllerProvider).bucketId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
