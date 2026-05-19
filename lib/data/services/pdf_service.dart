import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/person_analysis.dart';
import '../models/person_premium_analysis.dart';
import '../models/relationship_analysis.dart';
import '../models/relationship_premium_analysis.dart';

class _PersonTitleData {
  final String name;
  final DateTime birthDate;
  const _PersonTitleData({required this.name, required this.birthDate});
}

// ─── Renk Paleti ─────────────────────────────────────────────────────────────
const _bg = PdfColor.fromInt(0xFF0A0E1A);
const _surface = PdfColor.fromInt(0xFF141C2E);
const _gold = PdfColor.fromInt(0xFFD4AF37);
const _goldLight = PdfColor.fromInt(0xFFE8C84A);
const _textPrimary = PdfColor.fromInt(0xFFF0EAD6);
const _textSecondary = PdfColor.fromInt(0xFFB0A890);
const _textMuted = PdfColor.fromInt(0xFF6B7280);
const _purple = PdfColor.fromInt(0xFF7C3AED);
const _border = PdfColor.fromInt(0xFF2D3748);

class PdfService {
  // ─── Tek Kişi Analizi PDF ─────────────────────────────────────────────────
  static Future<File> generatePersonAnalysis(PersonAnalysis a) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final cinzel = await PdfGoogleFonts.cinzelRegular();
    final cinzelBold = await PdfGoogleFonts.cinzelBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) => [
          _background(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(cinzel, cinzelBold),
                _divider(),
                _personTitle(_PersonTitleData(name: a.name, birthDate: a.birthDate), cinzelBold, font),
                _pinCodeRow(a.pinCode, font, fontBold),
                _divider(),
                _section('Özet', a.summary, fontBold, font),
                _section('Güçlü Yön', a.strength, fontBold, font),
                _section('Dikkat Edilmesi Gereken', a.warning, fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    return _save(pdf, 'analiz_${a.name.toLowerCase().replaceAll(' ', '_')}.pdf');
  }

  // ─── Premium Tekil PDF ────────────────────────────────────────────────────
  static Future<File> generatePersonPremium(PersonPremiumAnalysis a) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final cinzel = await PdfGoogleFonts.cinzelRegular();
    final cinzelBold = await PdfGoogleFonts.cinzelBold();

    final haneLabels = [
      'H1 — Kişilik', 'H2 — Sosyal Bilinç', 'H3 — Küresel Bakış',
      'H4 — Yaşam Döngüsü', 'H5 — Ders & Potansiyel', 'H6 — İçsel Benlik',
      'H7 — İçsel Çocuk', 'H8 — Ruh', 'H9 — Evren',
    ];
    final haneTexts = [
      a.h1Personality, a.h2Social, a.h3Global, a.h4LifeCycle,
      a.h5Lesson, a.h6InnerSelf, a.h7InnerChild, a.h8Soul, a.h9Universe,
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) => [
          _background(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(cinzel, cinzelBold),
                _divider(),
                _personTitle(
                  _PersonTitleData(name: a.name, birthDate: a.birthDate),
                  cinzelBold, font,
                  subtitle: 'Detaylı Kişilik Analizi',
                ),
                _pinCodeRow(a.pinCode, font, fontBold),
                _divider(),
                pw.SizedBox(height: 8),
                _badge('9 Hane Yorumu', cinzelBold),
                pw.SizedBox(height: 8),
                ...List.generate(9, (i) =>
                    _haneSection(haneLabels[i], haneTexts[i], a.pinCode[i], fontBold, font)),
                _divider(),
                _section('Element Profili', a.elementDetail, fontBold, font),
                _section('Yaşam Dersin', a.lifeLesson, fontBold, font),
                _section('Bu Yılın Mesajı', a.yearMessage, fontBold, font),
                _section('Genel Değerlendirme', a.overallSummary, fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    return _save(pdf, 'detayli_analiz_${a.name.toLowerCase().replaceAll(' ', '_')}.pdf');
  }

  // ─── İlişki Analizi PDF ───────────────────────────────────────────────────
  static Future<File> generateRelationshipAnalysis(RelationshipAnalysis a) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final cinzel = await PdfGoogleFonts.cinzelRegular();
    final cinzelBold = await PdfGoogleFonts.cinzelBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) => [
          _background(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(cinzel, cinzelBold),
                _divider(),
                _relationshipTitle(
                    a.firstName, a.firstPinCode,
                    a.secondName, a.secondPinCode,
                    a.relationshipType, cinzelBold, font),
                _divider(),
                _section('Genel Değerlendirme', a.summary, fontBold, font),
                _section('Uyum Noktaları', a.harmonyPoint, fontBold, font),
                _section('Zorluk Noktaları', a.challengePoint, fontBold, font),
                if (a.sexualCompatibility != null && a.sexualCompatibility!.isNotEmpty)
                  _section('Cinsel Uyum', a.sexualCompatibility!, fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    final name = '${a.firstName}_${a.secondName}'.toLowerCase().replaceAll(' ', '_');
    return _save(pdf, 'iliski_analizi_$name.pdf');
  }

  // ─── Premium İlişki PDF ───────────────────────────────────────────────────
  static Future<File> generateRelationshipPremium(RelationshipPremiumAnalysis a) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final cinzel = await PdfGoogleFonts.cinzelRegular();
    final cinzelBold = await PdfGoogleFonts.cinzelBold();

    final haneLabels = [
      'H1 — İlişki Kişiliği', 'H2 — Sosyal Dinamik', 'H3 — Ortak Vizyon',
      'H4 — Birliktelik Döngüsü', 'H5 — Ortak Ders', 'H6 — Gizli Bağ',
      'H7 — Çocuksu Taraf', 'H8 — Ruhsal Bağ', 'H9 — Evrensel Anlam',
    ];
    final haneTexts = [
      a.h1Combined, a.h2Combined, a.h3Combined, a.h4Combined, a.h5Combined,
      a.h6Combined, a.h7Combined, a.h8Combined, a.h9Combined,
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) => [
          _background(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(cinzel, cinzelBold),
                _divider(),
                _relationshipTitle(
                    a.firstName, a.firstPinCode,
                    a.secondName, a.secondPinCode,
                    a.relationshipType, cinzelBold, font,
                    subtitle: 'Detaylı İlişki Analizi',
                    combinedPin: a.combinedPinCode),
                _divider(),
                pw.SizedBox(height: 8),
                _badge('Birleşik Pin Kodu Yorumu', cinzelBold),
                pw.SizedBox(height: 8),
                ...List.generate(9, (i) =>
                    _haneSection(haneLabels[i], haneTexts[i], a.combinedPinCode[i], fontBold, font)),
                _divider(),
                _section('Element Uyumu', a.elementCompatibility, fontBold, font),
                _section('İletişim Tarzı', a.communicationStyle, fontBold, font),
                _section('Çatışma Kalıpları', a.conflictPatterns, fontBold, font),
                _section('Büyüme Fırsatı', a.growthOpportunity, fontBold, font),
                if (a.sexualCompatibility.isNotEmpty)
                  _section('Cinsel Uyum', a.sexualCompatibility, fontBold, font),
                _section('Bu Yılın Mesajı', a.yearMessage, fontBold, font),
                _section('Yaşam Dersi', a.lifeLesson, fontBold, font),
                _section('Genel Değerlendirme', a.overallSummary, fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    final name = '${a.firstName}_${a.secondName}'.toLowerCase().replaceAll(' ', '_');
    return _save(pdf, 'detayli_iliski_$name.pdf');
  }

  // ─── Yardımcı Widget'lar ──────────────────────────────────────────────────

  static pw.Widget _background({required pw.Widget child}) {
    return pw.Container(
      width: double.infinity,
      color: _bg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: child,
    );
  }

  static pw.Widget _header(pw.Font cinzel, pw.Font cinzelBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PIN KODUM',
                style: pw.TextStyle(
                    font: cinzelBold, fontSize: 22, color: _gold,
                    letterSpacing: 3)),
            pw.SizedBox(height: 2),
            pw.Text('Numeroloji Temelli Kişisel Farkındalık',
                style: pw.TextStyle(font: cinzel, fontSize: 9, color: _textMuted)),
          ],
        ),
        pw.Container(
          width: 42, height: 42,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: _gold,
          ),
          alignment: pw.Alignment.center,
          child: pw.Text('✦',
              style: pw.TextStyle(font: cinzelBold, fontSize: 20, color: _bg)),
        ),
      ],
    );
  }

  static pw.Widget _divider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 16),
      child: pw.Container(height: 0.5, color: _border),
    );
  }

  static pw.Widget _personTitle(
    _PersonTitleData a,
    pw.Font cinzelBold,
    pw.Font font, {
    String? subtitle,
  }) {
    final day = a.birthDate.day.toString().padLeft(2, '0');
    final month = a.birthDate.month.toString().padLeft(2, '0');
    final year = a.birthDate.year;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(a.name,
            style: pw.TextStyle(font: cinzelBold, fontSize: 26, color: _gold)),
        pw.SizedBox(height: 4),
        pw.Text('$day.$month.$year',
            style: pw.TextStyle(font: font, fontSize: 12, color: _textSecondary)),
        if (subtitle != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(subtitle,
              style: pw.TextStyle(font: font, fontSize: 10, color: _textMuted)),
        ],
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _relationshipTitle(
    String name1, List<int> pin1,
    String name2, List<int> pin2,
    String relType,
    pw.Font cinzelBold, pw.Font font, {
    String? subtitle,
    List<int>? combinedPin,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(name1,
                      style: pw.TextStyle(font: cinzelBold, fontSize: 18, color: _gold)),
                  pw.Text(pin1.join('-'),
                      style: pw.TextStyle(font: font, fontSize: 10, color: _textMuted,
                          letterSpacing: 2)),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _border), borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Text('♥',
                  style: pw.TextStyle(font: cinzelBold, fontSize: 14, color: _purple)),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(name2,
                      style: pw.TextStyle(font: cinzelBold, fontSize: 18, color: _gold)),
                  pw.Text(pin2.join('-'),
                      style: pw.TextStyle(font: font, fontSize: 10, color: _textMuted,
                          letterSpacing: 2)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(relType,
            style: pw.TextStyle(font: font, fontSize: 10, color: _textMuted)),
        if (combinedPin != null) ...[
          pw.SizedBox(height: 4),
          pw.Text('Birleşik: ${combinedPin.join('-')}',
              style: pw.TextStyle(font: font, fontSize: 10, color: _gold)),
        ],
        if (subtitle != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(subtitle,
              style: pw.TextStyle(font: font, fontSize: 10, color: _textMuted)),
        ],
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _pinCodeRow(List<int> pinCode, pw.Font font, pw.Font fontBold) {
    const colors = [
      _gold, _purple, PdfColor.fromInt(0xFF60A5FA), PdfColor.fromInt(0xFF34D399),
      _gold, PdfColor.fromInt(0xFFF472B6), _purple,
      PdfColor.fromInt(0xFF60A5FA), _gold,
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PIN KODU',
            style: pw.TextStyle(font: font, fontSize: 9, color: _textMuted, letterSpacing: 2)),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: List.generate(pinCode.length, (i) {
            final c = i < colors.length ? colors[i] : _gold;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(right: 6),
              child: pw.Container(
                width: 36, height: 36,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: _surface,
                  border: pw.Border.all(color: c, width: 1.5),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text('${pinCode[i]}',
                    style: pw.TextStyle(font: fontBold, fontSize: 16, color: c)),
              ),
            );
          }),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _section(String title, String content, pw.Font fontBold, pw.Font font) {
    if (content.trim().isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: _surface,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border(left: pw.BorderSide(color: _gold, width: 3)),
            ),
            child: pw.Text(title,
                style: pw.TextStyle(font: fontBold, fontSize: 11, color: _gold)),
          ),
          pw.SizedBox(height: 8),
          pw.Text(content,
              style: pw.TextStyle(font: font, fontSize: 10.5, color: _textPrimary,
                  lineSpacing: 4)),
        ],
      ),
    );
  }

  static pw.Widget _haneSection(
      String label, String content, int digit, pw.Font fontBold, pw.Font font) {
    if (content.trim().isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 32, height: 32,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: _surface,
              border: pw.Border.all(color: _gold, width: 1),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text('$digit',
                style: pw.TextStyle(font: fontBold, fontSize: 14, color: _gold)),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(label,
                    style: pw.TextStyle(font: fontBold, fontSize: 10, color: _goldLight)),
                pw.SizedBox(height: 4),
                pw.Text(content,
                    style: pw.TextStyle(font: font, fontSize: 10, color: _textPrimary,
                        lineSpacing: 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _badge(String label, pw.Font cinzelBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _gold.shade(0.3)),
      ),
      child: pw.Text(label,
          style: pw.TextStyle(font: cinzelBold, fontSize: 11, color: _gold, letterSpacing: 1)),
    );
  }

  static pw.Widget _footer(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 24),
      child: pw.Column(
        children: [
          pw.Container(height: 0.5, color: _border),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Pin Kodum • pinkodum.app',
                  style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
              pw.Text('Bu rapor numeroloji temelli kişisel farkındalık amacıyla hazırlanmıştır.',
                  style: pw.TextStyle(font: font, fontSize: 7, color: _textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Dosyaya Kaydet ───────────────────────────────────────────────────────
  static Future<File> _save(pw.Document pdf, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ─── Paylaş ───────────────────────────────────────────────────────────────
  static Future<void> share(File file, {String? subject}) async {
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
      subject: subject,
    );
  }
}
