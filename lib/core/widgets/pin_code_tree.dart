import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Pin kodunu orijinal şablona göre hiyerarşik ağaç yapısında gösterir.
///
///  [H1] [H2] [H3] [H4] [H5]
///       [H6] [H7]
///          [H8]        [H9]
class PinCodeTree extends StatelessWidget {
  final List<int> pinCode;

  const PinCodeTree({super.key, required this.pinCode});

  static const _haneNames = [
    'Kişilik',
    'Sosyal Bilinç',
    'Küresel Bilinçlilik',
    'Yaşam Döngüsü',
    'Ders',
    'İçsel Benlik',
    'İçsel Çocuk',
    'Ruh Duygusu',
    'Evren',
  ];

  // Her haneye özgü renk
  static const _haneColors = [
    Color(0xFFD4AF37), // H1 — altın
    Color(0xFF9D5FF0), // H2 — mor
    Color(0xFF60A5FA), // H3 — mavi
    Color(0xFF34D399), // H4 — yeşil
    Color(0xFFF97316), // H5 — turuncu
    Color(0xFFF472B6), // H6 — pembe
    Color(0xFFA78BFA), // H7 — lavanta
    Color(0xFF38BDF8), // H8 — açık mavi
    Color(0xFFD4AF37), // H9 — altın (özel)
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final W = constraints.maxWidth;
      const gap = 5.0;
      final colW = (W - 4 * gap) / 5;
      const rowH = 82.0;
      const rowGap = 8.0;
      const totalH = rowH * 3 + rowGap * 2;

      // Hane kutularının merkez X koordinatları (bağlantı çizgileri için)
      final cx = List.generate(
          5, (i) => i * (colW + gap) + colW / 2); // H1-H5 top row

      // H6 merkezi: col 1 pozisyonu
      final cx6 = colW + gap + colW / 2;
      // H7 merkezi: col 2 pozisyonu
      final cx7 = 2 * (colW + gap) + colW / 2;
      // H8 merkezi: H6+H7 orta noktası
      final cx8 = colW + gap + (colW * 2 + gap) / 2;
      // H9 merkezi: col 3-4 orta noktası
      final cx9 = 3 * (colW + gap) + (colW * 2 + gap) / 2;

      return SizedBox(
        height: totalH,
        child: Stack(children: [
          // ── Bağlantı çizgileri (arkada) ──────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _ConnectionPainter(
                colW: colW,
                gap: gap,
                rowH: rowH,
                rowGap: rowGap,
                cx2: cx[1],
                cx3: cx[2],
                cx6: cx6,
                cx7: cx7,
                cx8: cx8,
                cx9: cx9,
              ),
            ),
          ),

          // ── Satır 1: H1–H5 ───────────────────────────────────────────────
          for (int i = 0; i < 5; i++)
            Positioned(
              left: i * (colW + gap),
              top: 0,
              width: colW,
              height: rowH,
              child: _HaneBox(
                haneNum: i + 1,
                digit: pinCode[i],
                name: _haneNames[i],
                color: _haneColors[i],
              ),
            ),

          // ── Satır 2: H6 ve H7 ────────────────────────────────────────────
          Positioned(
            left: colW + gap,
            top: rowH + rowGap,
            width: colW,
            height: rowH,
            child: _HaneBox(
              haneNum: 6,
              digit: pinCode[5],
              name: _haneNames[5],
              color: _haneColors[5],
            ),
          ),
          Positioned(
            left: 2 * (colW + gap),
            top: rowH + rowGap,
            width: colW,
            height: rowH,
            child: _HaneBox(
              haneNum: 7,
              digit: pinCode[6],
              name: _haneNames[6],
              color: _haneColors[6],
            ),
          ),

          // ── Satır 3: H8 (H6+H7 genişliği) ve H9 (H4+H5 genişliği) ──────
          Positioned(
            left: colW + gap,
            top: 2 * (rowH + rowGap),
            width: colW * 2 + gap,
            height: rowH,
            child: _HaneBox(
              haneNum: 8,
              digit: pinCode[7],
              name: _haneNames[7],
              color: _haneColors[7],
              wide: true,
            ),
          ),
          Positioned(
            left: 3 * (colW + gap),
            top: 2 * (rowH + rowGap),
            width: colW * 2 + gap,
            height: rowH,
            child: _HaneBox(
              haneNum: 9,
              digit: pinCode[8],
              name: _haneNames[8],
              color: _haneColors[8],
              wide: true,
              special: true,
            ),
          ),
        ]),
      );
    });
  }
}

// ─── Bağlantı çizgileri ───────────────────────────────────────────────────────
class _ConnectionPainter extends CustomPainter {
  final double colW, gap, rowH, rowGap;
  final double cx2, cx3, cx6, cx7, cx8, cx9;

  const _ConnectionPainter({
    required this.colW,
    required this.gap,
    required this.rowH,
    required this.rowGap,
    required this.cx2,
    required this.cx3,
    required this.cx6,
    required this.cx7,
    required this.cx8,
    required this.cx9,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final row1Bottom = rowH;
    final row2Top = rowH + rowGap;
    final row2Bottom = rowH * 2 + rowGap;
    final row3Top = rowH * 2 + rowGap * 2;

    // H2 → H6
    _drawLine(canvas, paint, cx2, row1Bottom, cx6, row2Top);
    // H3 → H7
    _drawLine(canvas, paint, cx3, row1Bottom, cx7, row2Top);
    // H6 → H8
    _drawLine(canvas, paint, cx6, row2Bottom, cx8, row3Top);
    // H7 → H8
    _drawLine(canvas, paint, cx7, row2Bottom, cx8, row3Top);
  }

  void _drawLine(Canvas c, Paint p, double x1, double y1, double x2, double y2) {
    c.drawLine(Offset(x1, y1), Offset(x2, y2), p);
  }

  @override
  bool shouldRepaint(_ConnectionPainter old) => false;
}

// ─── Tek hane kutusu ─────────────────────────────────────────────────────────
class _HaneBox extends StatelessWidget {
  final int haneNum;
  final int digit;
  final String name;
  final Color color;
  final bool wide;
  final bool special; // H9 için özel parlak stil

  const _HaneBox({
    required this.haneNum,
    required this.digit,
    required this.name,
    required this.color,
    this.wide = false,
    this.special = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: special
            ? color.withValues(alpha: 0.12)
            : AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: special ? 0.7 : 0.4),
          width: special ? 1.5 : 1,
        ),
        boxShadow: special
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                )
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hane numarası
          Text(
            'H$haneNum',
            style: GoogleFonts.inter(
              fontSize: 8,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 1),
          // Rakam
          Text(
            '$digit',
            style: GoogleFonts.cinzel(
              fontSize: special ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          // Hane adı — overflow korumalı
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: wide ? 8.5 : 7.5,
                color: AppColors.textSecondary,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
