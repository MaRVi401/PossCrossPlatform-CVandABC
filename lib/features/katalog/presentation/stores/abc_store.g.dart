// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abc_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ABCStore on _ABCStoreBase, Store {
  late final _$bundleAtom =
      Atom(name: '_ABCStoreBase.bundle', context: context);

  @override
  BundleModel? get bundle {
    _$bundleAtom.reportRead();
    return super.bundle;
  }

  @override
  set bundle(BundleModel? value) {
    _$bundleAtom.reportWrite(value, super.bundle, () {
      super.bundle = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ABCStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ABCStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$generateBundlesAsyncAction =
      AsyncAction('_ABCStoreBase.generateBundles', context: context);

  @override
  Future<void> generateBundles() {
    return _$generateBundlesAsyncAction.run(() => super.generateBundles());
  }

  @override
  String toString() {
    return '''
bundle: ${bundle},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
