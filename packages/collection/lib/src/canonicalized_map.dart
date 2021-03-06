// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'utils.dart';

typedef C _Canonicalize<C, K>(K key);

typedef bool _IsValidKey(Object key);

/// A map whose keys are converted to canonical values of type `C`.
///
/// This is useful for using case-insensitive String keys, for example. It's
/// more efficient than a [LinkedHashMap] with a custom equality operator
/// because it only canonicalizes each key once, rather than doing so for each
/// comparison.
///
/// By default, `null` is allowed as a key. It can be forbidden via the
/// `isValidKey` parameter.
class CanonicalizedMap<C, K, V> implements Map<K, V> {
  final _Canonicalize<C, K> _canonicalize;

  final _IsValidKey _isValidKeyFn;

  final _base = new Map<C, Pair<K, V>>();

  /// Creates an empty canonicalized map.
  ///
  /// The [canonicalize] function should return the canonical value for the
  /// given key. Keys with the same canonical value are considered equivalent.
  ///
  /// The [isValidKey] function is called before calling [canonicalize] for
  /// methods that take arbitrary objects. It can be used to filter out keys
  /// that can't be canonicalized.
  CanonicalizedMap(C canonicalize(K key), {bool isValidKey(Object key)})
      : _canonicalize = canonicalize,
        _isValidKeyFn = isValidKey;

  /// Creates a canonicalized map that is initialized with the key/value pairs
  /// of [other].
  ///
  /// The [canonicalize] function should return the canonical value for the
  /// given key. Keys with the same canonical value are considered equivalent.
  ///
  /// The [isValidKey] function is called before calling [canonicalize] for
  /// methods that take arbitrary objects. It can be used to filter out keys
  /// that can't be canonicalized.
  CanonicalizedMap.from(Map<K, V> other, C canonicalize(K key),
      {bool isValidKey(Object key)})
      : _canonicalize = canonicalize,
        _isValidKeyFn = isValidKey {
    addAll(other);
  }

  V operator [](Object key) {
    if (!_isValidKey(key)) return null;
    var pair = _base[_canonicalize(key as K)];
    return pair == null ? null : pair.last;
  }

  void operator []=(K key, V value) {
    if (!_isValidKey(key)) return;
    _base[_canonicalize(key)] = new Pair(key, value);
  }

  void addAll(Map<K, V> other) {
    other.forEach((key, value) => this[key] = value);
  }

  void addEntries(Iterable<MapEntry<K, V>> entries) =>
      _base.addEntries(entries.map(
          (e) => new MapEntry(_canonicalize(e.key), new Pair(e.key, e.value))));

  Map<K2, V2> cast<K2, V2>() => _base.cast<K2, V2>();

  void clear() {
    _base.clear();
  }

  bool containsKey(Object key) {
    if (!_isValidKey(key)) return false;
    return _base.containsKey(_canonicalize(key as K));
  }

  bool containsValue(Object value) =>
      _base.values.any((pair) => pair.last == value);

  Iterable<MapEntry<K, V>> get entries =>
      _base.entries.map((e) => new MapEntry(e.value.first, e.value.last));

  void forEach(void f(K key, V value)) {
    _base.forEach((key, pair) => f(pair.first, pair.last));
  }

  bool get isEmpty => _base.isEmpty;

  bool get isNotEmpty => _base.isNotEmpty;

  Iterable<K> get keys => _base.values.map((pair) => pair.first);

  int get length => _base.length;

  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> transform(K key, V value)) =>
      _base.map((_, pair) => transform(pair.first, pair.last));

  V putIfAbsent(K key, V ifAbsent()) {
    return _base
        .putIfAbsent(_canonicalize(key), () => new Pair(key, ifAbsent()))
        .last;
  }

  V remove(Object key) {
    if (!_isValidKey(key)) return null;
    var pair = _base.remove(_canonicalize(key as K));
    return pair == null ? null : pair.last;
  }

  void removeWhere(bool test(K key, V value)) =>
      _base.removeWhere((_, pair) => test(pair.first, pair.last));

  Map<K2, V2> retype<K2, V2>() => _base.retype<K2, V2>();

  V update(K key, V update(V value), {V ifAbsent()}) => _base
      .update(_canonicalize(key), (pair) => new Pair(key, update(pair.last)),
          ifAbsent: ifAbsent == null ? null : () => new Pair(key, ifAbsent()))
      .last;

  void updateAll(V update(K key, V value)) => _base.updateAll(
      (_, pair) => new Pair(pair.first, update(pair.first, pair.last)));

  Iterable<V> get values => _base.values.map((pair) => pair.last);

  String toString() {
    // Detect toString() cycles.
    if (_isToStringVisiting(this)) {
      return '{...}';
    }

    var result = new StringBuffer();
    try {
      _toStringVisiting.add(this);
      result.write('{');
      bool first = true;
      forEach((k, v) {
        if (!first) {
          result.write(', ');
        }
        first = false;
        result.write('$k: $v');
      });
      result.write('}');
    } finally {
      assert(identical(_toStringVisiting.last, this));
      _toStringVisiting.removeLast();
    }

    return result.toString();
  }

  bool _isValidKey(Object key) =>
      (key == null || key is K) &&
      (_isValidKeyFn == null || _isValidKeyFn(key));
}

/// A collection used to identify cyclic maps during toString() calls.
final List _toStringVisiting = [];

/// Check if we are currently visiting `o` in a toString() call.
bool _isToStringVisiting(o) => _toStringVisiting.any((e) => identical(o, e));
