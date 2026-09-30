/// Digest helpers built on package:crypto.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

enum HashAlgorithm {
  md5('MD5'),
  sha1('SHA-1'),
  sha256('SHA-256'),
  sha512('SHA-512');

  const HashAlgorithm(this.label);
  final String label;

  crypto.Hash get _hash => switch (this) {
        HashAlgorithm.md5 => crypto.md5,
        HashAlgorithm.sha1 => crypto.sha1,
        HashAlgorithm.sha256 => crypto.sha256,
        HashAlgorithm.sha512 => crypto.sha512,
      };

  /// MD5 and SHA-1 are broken for collision resistance.
  bool get isWeak => this == HashAlgorithm.md5 || this == HashAlgorithm.sha1;
}

/// Lower-case hex digest of the UTF-8 bytes of [text]. When [hmacKey] is
/// non-null the HMAC of [text] with that key is returned instead.
String digestHex(HashAlgorithm algorithm, String text, {String? hmacKey}) {
  final bytes = utf8.encode(text);
  if (hmacKey != null) {
    return crypto.Hmac(algorithm._hash, utf8.encode(hmacKey))
        .convert(bytes)
        .toString();
  }
  return algorithm._hash.convert(bytes).toString();
}

Map<HashAlgorithm, String> allDigests(String text, {String? hmacKey}) => {
      for (final a in HashAlgorithm.values)
        a: digestHex(a, text, hmacKey: hmacKey),
    };

/// Normalises a pasted digest (trims, drops spaces/colons, lower-cases).
String normaliseDigest(String input) =>
    input.replaceAll(RegExp(r'[\s:]'), '').toLowerCase();

/// Which algorithm's digest equals [expected], or null if none match.
HashAlgorithm? matchDigest(
    Map<HashAlgorithm, String> digests, String expected) {
  final e = normaliseDigest(expected);
  if (e.isEmpty) return null;
  for (final entry in digests.entries) {
    if (_constantTimeEquals(entry.value, e)) return entry.key;
  }
  return null;
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
