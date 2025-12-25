import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeApiService {
  static Future<List<String>> fetchHeroBanners() async {
    try {
      final res = await http.get(
        Uri.parse("https://example.com/api/home/banners"),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final data = decoded is List ? decoded : [];
        return data.map((e) => e['imageUrl'] as String).toList();
      }
    } catch (_) {}

    return []; // ❌ API failed → fallback used
  }
}
