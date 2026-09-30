import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/hashing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _text = TextEditingController(text: 'hello');
  final _key = TextEditingController();
  final _expected = TextEditingController();
  bool _hmac = false;

  @override
  void dispose() {
    _text.dispose();
    _key.dispose();
    _expected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digests = allDigests(_text.text, hmacKey: _hmac ? _key.text : null);
    final expected = _expected.text.trim();
    final match = matchDigest(digests, expected);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hashgen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('text-input'),
            controller: _text,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Text to hash (UTF-8)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          SwitchListTile(
            key: const Key('hmac-switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('HMAC mode'),
            value: _hmac,
            onChanged: (v) => setState(() => _hmac = v),
          ),
          if (_hmac)
            TextField(
              key: const Key('key-input'),
              controller: _key,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'HMAC key',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 8),
          for (final a in HashAlgorithm.values)
            Card(
              child: ListTile(
                title: Text(
                  '${_hmac ? 'HMAC-' : ''}${a.label}'
                  '${a.isWeak ? ' (not for security)' : ''}',
                ),
                subtitle: SelectableText(
                  digests[a]!,
                  key: Key('digest-${a.name}'),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                trailing: IconButton(
                  tooltip: 'Copy ${a.label}',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: digests[a]!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${a.label} copied')),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('expected-input'),
            controller: _expected,
            decoration: const InputDecoration(
              labelText: 'Compare with expected digest',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (expected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                match == null ? 'No match' : 'Matches ${match.label}',
                key: const Key('match-result'),
                style: TextStyle(
                  color: match == null ? colors.error : colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
