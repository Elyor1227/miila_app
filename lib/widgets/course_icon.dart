import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/api_client.dart';

/// Kurs ikonkasi — bazadagi `icon` qiymatining har qanday ko'rinishini to'g'ri
/// render qiladi:
///  · "svgN.svg" bilan tugagan yo'l (masalan "/Untitled (9)/svg1.svg") —
///    ilova ichidagi assets/icons/svgN.svg dan olinadi (fayllar serverda yo'q);
///  · to'liq http(s) URL — tarmoqdan yuklanadi (.svg yoki rasm);
///  · emoji yoki qisqa matn — Text sifatida;
///  · bo'sh/yaroqsiz — 📚 fallback.
class CourseIcon extends StatelessWidget {
  final String icon;
  final double size;

  const CourseIcon(this.icon, {super.key, this.size = 22});

  static final _bundledSvg = RegExp(r'(svg\d+)\.svg$');

  @override
  Widget build(BuildContext context) {
    final value = icon.trim();

    // 1) Ilova ichidagi svg (svg1..svg6)
    final bundled = _bundledSvg.firstMatch(value);
    if (bundled != null) {
      return SvgPicture.asset(
        'assets/icons/${bundled.group(1)}.svg',
        width: size,
        height: size,
      );
    }

    // 2) To'liq yoki nisbiy URL
    if (value.startsWith('http') || value.startsWith('/')) {
      final url = value.startsWith('http')
          ? value
          : ApiClient.baseUrl.replaceFirst(RegExp(r'/api$'), '') + value;
      if (value.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          url,
          width: size,
          height: size,
          placeholderBuilder: (_) => _fallback(),
        );
      }
      return Image.network(
        url,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // 3) Emoji / qisqa matn
    if (value.isNotEmpty && value.length <= 4) {
      return Text(value, style: TextStyle(fontSize: size * 0.85));
    }

    return _fallback();
  }

  Widget _fallback() => Text('📚', style: TextStyle(fontSize: size * 0.85));
}
