import 'package:flutter_test/flutter_test.dart';
import 'package:hashgen/logic/hashing.dart';

void main() {
  test('known digests of "abc"', () {
    expect(digestHex(HashAlgorithm.md5, 'abc'),
        '900150983cd24fb0d6963f7d28e17f72');
    expect(digestHex(HashAlgorithm.sha1, 'abc'),
        'a9993e364706816aba3e25717850c26c9cd0d89d');
    expect(
      digestHex(HashAlgorithm.sha256, 'abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    expect(
        digestHex(HashAlgorithm.sha512, 'abc'), startsWith('ddaf35a193617aba'));
  });

  test('empty string and UTF-8 input', () {
    expect(
      digestHex(HashAlgorithm.sha256, ''),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    // "é" is two UTF-8 bytes; MD5 of c3 a9.
    expect(digestHex(HashAlgorithm.md5, 'é'),
        isNot(digestHex(HashAlgorithm.md5, 'e')));
  });

  test('HMAC matches RFC 4231 test case 2', () {
    expect(
      digestHex(
        HashAlgorithm.sha256,
        'what do ya want for nothing?',
        hmacKey: 'Jefe',
      ),
      '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843',
    );
  });

  test('matchDigest normalises input and finds the algorithm', () {
    final d = allDigests('abc');
    expect(matchDigest(d, ' 900150983CD24FB0D6963F7D28E17F72 '),
        HashAlgorithm.md5);
    expect(
        matchDigest(
            d, 'a9:99:3e:36:47:06:81:6a:ba:3e:25:71:78:50:c2:6c:9c:d0:d8:9d'),
        HashAlgorithm.sha1);
    expect(matchDigest(d, 'deadbeef'), isNull);
    expect(matchDigest(d, '  '), isNull);
  });

  test('weak algorithms are flagged', () {
    expect(HashAlgorithm.md5.isWeak, isTrue);
    expect(HashAlgorithm.sha256.isWeak, isFalse);
  });
}
