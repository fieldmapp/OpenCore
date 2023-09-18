// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doc_list.controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$docListControllerHash() => r'64d8cdd82d62bba3161ddf87eb9c5029726fa09f';

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

abstract class _$DocListController
    extends BuildlessAutoDisposeAsyncNotifier<List<Document>> {
  late final String collectionID;

  Future<List<Document>> build(
    String collectionID,
  );
}

/// See also [DocListController].
@ProviderFor(DocListController)
const docListControllerProvider = DocListControllerFamily();

/// See also [DocListController].
class DocListControllerFamily extends Family<AsyncValue<List<Document>>> {
  /// See also [DocListController].
  const DocListControllerFamily();

  /// See also [DocListController].
  DocListControllerProvider call(
    String collectionID,
  ) {
    return DocListControllerProvider(
      collectionID,
    );
  }

  @override
  DocListControllerProvider getProviderOverride(
    covariant DocListControllerProvider provider,
  ) {
    return call(
      provider.collectionID,
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
  String? get name => r'docListControllerProvider';
}

/// See also [DocListController].
class DocListControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DocListController, List<Document>> {
  /// See also [DocListController].
  DocListControllerProvider(
    String collectionID,
  ) : this._internal(
          () => DocListController()..collectionID = collectionID,
          from: docListControllerProvider,
          name: r'docListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$docListControllerHash,
          dependencies: DocListControllerFamily._dependencies,
          allTransitiveDependencies:
              DocListControllerFamily._allTransitiveDependencies,
          collectionID: collectionID,
        );

  DocListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collectionID,
  }) : super.internal();

  final String collectionID;

  @override
  Future<List<Document>> runNotifierBuild(
    covariant DocListController notifier,
  ) {
    return notifier.build(
      collectionID,
    );
  }

  @override
  Override overrideWith(DocListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DocListControllerProvider._internal(
        () => create()..collectionID = collectionID,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collectionID: collectionID,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DocListController, List<Document>>
      createElement() {
    return _DocListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocListControllerProvider &&
        other.collectionID == collectionID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collectionID.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DocListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Document>> {
  /// The parameter `collectionID` of this provider.
  String get collectionID;
}

class _DocListControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DocListController,
        List<Document>> with DocListControllerRef {
  _DocListControllerProviderElement(super.provider);

  @override
  String get collectionID => (origin as DocListControllerProvider).collectionID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
