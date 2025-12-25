import 'package:flutter_dotenv/flutter_dotenv.dart';

String resolveImageUrl(String? url) {
  if (url == null) return '';

  // 🚀 If HTTPS, return directly (NO TRIM / NO TOUCH)
  if (url.startsWith('https://')) {
    return url;
  }

  // ⚠ For everything else → trim
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';

  // ✅ Allow http explicitly (Android needs cleartext enabled)
  if (trimmed.startsWith('http://')) {
    return trimmed;
  }

  // 🧩 Relative URL → attach base
  final base = dotenv.env['API_BASE_URL'] ?? '';
  if (base.isEmpty) return trimmed;

  if (trimmed.startsWith('/')) {
    return base + trimmed;
  }

  return '$base/$trimmed';
}
