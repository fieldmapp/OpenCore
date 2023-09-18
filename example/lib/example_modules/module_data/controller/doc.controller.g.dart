// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doc.controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$docControllerHash() => r'7c2a9dc22351d5a53a652b4062af37efa2787628';

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

abstract class _$DocController
    extends BuildlessAutoDisposeAsyncNotifier<Document> {
  late final String collectionID;
  late final String docId;
  late final String? revision;

  Future<Document> build(
    String collectionID,
    String docId,
    String? revision,
  );
}

/// See also [DocController].
@ProviderFor(DocController)
const docControllerProvider = DocControllerFamily();

/// See also [DocController].
class DocControllerFamily extends Family<AsyncValue<Document>> {
  /// See also [DocController].
  const DocControllerFamily();

  /// See also [DocController].
  DocControllerProvider call(
    String collectionID,
    String docId,
    String? revision,
  ) {
    return DocControllerProvider(
      collectionID,
      docId,
      revision,
    );
  }

  @override
  DocControllerProvider getProviderOverride(
    covariant DocControllerProvider provider,
  ) {
    return call(
      provider.collectionID,
      provider.docId,
      provider.revision,
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
  String? get name => r'docControllerProvider';
}

/// See also [DocController].
class DocControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DocController, Document> {
  /// See also [DocController].
  DocControllerProvider(
    String collectionID,
    String docId,
    String? revision,
  ) : this._internal(
          () => DocController()
            ..collectionID = collectionID
            ..docId = docId
            ..revision = revision,
          from: docControllerProvider,
          name: r'docControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$docControllerHash,
          dependencies: DocControllerFamily._dependencies,
          allTransitiveDependencies:
              DocControllerFamily._allTransitiveDependencies,
          collectionID: collectionID,
          docId: docId,
          revision: revision,
        );

  DocControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collectionID,
    required this.docId,
    required this.revision,
  }) : super.internal();

  final String collectionID;
  final String docId;
  final String? revision;

  @override
  Future<Document> runNotifierBuild(
    covariant DocController notifier,
  ) {
    return notifier.build(
      collectionID,
      docId,
      revision,
    );
  }

  @override
  Override overrideWith(DocController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DocControllerProvider._internal(
        () => create()
          ..collectionID = collectionID
          ..docId = docId
          ..revision = revision,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collectionID: collectionID,
        docId: docId,
        revision: revision,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DocController, Document>
      createElement() {
    return _DocControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocControllerProvider &&
        other.collectionID == collectionID &&
        other.docId == docId &&
        other.revision == revision;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collectionID.hashCode);
    hash = _SystemHash.combine(hash, docId.hashCode);
    hash = _SystemHash.combine(hash, revision.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DocControllerRef on AutoDisposeAsyncNotifierProviderRef<Document> {
  /// The parameter `collectionID` of this provider.
  String get collectionID;

  /// The parameter `docId` of this provider.
  String get docId;

  /// The parameter `revision` of this provider.
  String? get revision;
}

class _DocControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DocController, Document>
    with DocControllerRef {
  _DocControllerProviderElement(super.provider);

  @override
  String get collectionID => (origin as DocControllerProvider).collectionID;
  @override
  String get docId => (origin as DocControllerProvider).docId;
  @override
  String? get revision => (origin as DocControllerProvider).revision;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
