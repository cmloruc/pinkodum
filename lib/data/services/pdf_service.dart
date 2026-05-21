import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/element_balance.dart';
import '../models/person_analysis.dart';
import '../models/person_premium_analysis.dart';
import '../models/relationship_analysis.dart';
import '../models/relationship_premium_analysis.dart';
import 'element_balance_calculator.dart';

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
                _personTitle(
                    _PersonTitleData(name: a.name, birthDate: a.birthDate),
                    cinzelBold,
                    font),
                _pinCodeTree(a.pinCode, font, fontBold),
                pw.SizedBox(height: 12),
                _elementPanel(a.elementBalance, fontBold, font),
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

    return _save(
        pdf, 'analiz_${a.name.toLowerCase().replaceAll(' ', '_')}.pdf');
  }

  // ─── Premium Tekil PDF ────────────────────────────────────────────────────
  static Future<File> generatePersonPremium(PersonPremiumAnalysis a) async {
    final pdf = await _buildPersonPremiumDocument(a);
    return _save(
        pdf, 'detayli_analiz_${a.name.toLowerCase().replaceAll(' ', '_')}.pdf');
  }

  static Future<bool> sharePersonPremium(PersonPremiumAnalysis a,
      {String? subject}) async {
    final pdf = await _buildPersonPremiumDocument(a);
    return _shareBytes(
      await pdf.save(),
      filename:
          'detayli_analiz_${a.name.toLowerCase().replaceAll(' ', '_')}.pdf',
      subject: subject,
    );
  }

  static Future<pw.Document> _buildPersonPremiumDocument(
      PersonPremiumAnalysis a) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final cinzel = await PdfGoogleFonts.cinzelRegular();
    final cinzelBold = await PdfGoogleFonts.cinzelBold();

    final haneLabels = [
      'H1 — Kişilik',
      'H2 — Sosyal Bilinç',
      'H3 — Küresel Bakış',
      'H4 — Yaşam Döngüsü',
      'H5 — Ders & Potansiyel',
      'H6 — İçsel Benlik',
      'H7 — İçsel Çocuk',
      'H8 — Ruh',
      'H9 — Evren',
    ];
    final haneTexts = [
      a.h1Personality,
      a.h2Social,
      a.h3Global,
      a.h4LifeCycle,
      a.h5Lesson,
      a.h6InnerSelf,
      a.h7InnerChild,
      a.h8Soul,
      a.h9Universe,
    ];
    final elementBalance =
        const ElementBalanceCalculator().calculate(a.pinCode);

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
                  cinzelBold,
                  font,
                  subtitle: 'Detaylı Kişilik Analizi',
                ),
                _pinCodeTree(a.pinCode, font, fontBold),
                pw.SizedBox(height: 12),
                _elementPanel(elementBalance, fontBold, font),
                _divider(),
                pw.SizedBox(height: 8),
                _badge('9 Hane Yorumu', cinzelBold),
                pw.SizedBox(height: 8),
                ...List.generate(
                    9,
                    (i) => _haneSection(haneLabels[i], haneTexts[i],
                        a.pinCode[i], fontBold, font)),
                _divider(),
                _section('Element Profili', a.elementDetail, fontBold, font),
                _section('Yaşam Dersin', a.lifeLesson, fontBold, font),
                _section('Bu Yılın Mesajı', a.yearMessage, fontBold, font),
                _section('Genel Değerlendirme', a.resolvedOverallSummary,
                    fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  // ─── İlişki Analizi PDF ───────────────────────────────────────────────────
  static Future<File> generateRelationshipAnalysis(
      RelationshipAnalysis a) async {
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
                _relationshipTitle(a.firstName, a.firstPinCode, a.secondName,
                    a.secondPinCode, a.relationshipType, cinzelBold, font),
                _elementPanel(a.combinedElementBalance, fontBold, font,
                    title: 'Ortak Element Haritası'),
                _divider(),
                _section('Genel Değerlendirme', a.summary, fontBold, font),
                _section('Uyum Noktaları', a.harmonyPoint, fontBold, font),
                _section('Zorluk Noktaları', a.challengePoint, fontBold, font),
                if (a.sexualCompatibility != null &&
                    a.sexualCompatibility!.isNotEmpty)
                  _section(
                      'Cinsel Uyum', a.sexualCompatibility!, fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    final name =
        '${a.firstName}_${a.secondName}'.toLowerCase().replaceAll(' ', '_');
    return _save(pdf, 'iliski_analizi_$name.pdf');
  }

  // ─── Premium İlişki PDF ───────────────────────────────────────────────────
  static Future<File> generateRelationshipPremium(
      RelationshipPremiumAnalysis a) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final cinzel = await PdfGoogleFonts.cinzelRegular();
    final cinzelBold = await PdfGoogleFonts.cinzelBold();

    final haneLabels = [
      'H1 — İlişki Kişiliği',
      'H2 — Sosyal Dinamik',
      'H3 — Ortak Vizyon',
      'H4 — Birliktelik Döngüsü',
      'H5 — Ortak Ders',
      'H6 — Gizli Bağ',
      'H7 — Çocuksu Taraf',
      'H8 — Ruhsal Bağ',
      'H9 — Evrensel Anlam',
    ];
    final haneTexts = [
      a.h1Combined,
      a.h2Combined,
      a.h3Combined,
      a.h4Combined,
      a.h5Combined,
      a.h6Combined,
      a.h7Combined,
      a.h8Combined,
      a.h9Combined,
    ];
    final combinedElement =
        const ElementBalanceCalculator().calculate(a.combinedPinCode);

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
                _relationshipTitle(a.firstName, a.firstPinCode, a.secondName,
                    a.secondPinCode, a.relationshipType, cinzelBold, font,
                    subtitle: 'Detaylı İlişki Analizi',
                    combinedPin: a.combinedPinCode),
                _pinCodeTree(a.combinedPinCode, font, fontBold,
                    title: 'BİRLEŞİK PIN KODU'),
                pw.SizedBox(height: 12),
                _elementPanel(combinedElement, fontBold, font,
                    title: 'Ortak Element Haritası'),
                _divider(),
                pw.SizedBox(height: 8),
                _badge('Birleşik Pin Kodu Yorumu', cinzelBold),
                pw.SizedBox(height: 8),
                ...List.generate(
                    9,
                    (i) => _haneSection(haneLabels[i], haneTexts[i],
                        a.combinedPinCode[i], fontBold, font)),
                _divider(),
                _section(
                    'Element Uyumu', a.elementCompatibility, fontBold, font),
                _section(
                    'İletişim Tarzı', a.communicationStyle, fontBold, font),
                _section(
                    'Çatışma Kalıpları', a.conflictPatterns, fontBold, font),
                _section('Büyüme Fırsatı', a.growthOpportunity, fontBold, font),
                if (a.sexualCompatibility.isNotEmpty)
                  _section(
                      'Cinsel Uyum', a.sexualCompatibility, fontBold, font),
                _section('Bu Yılın Mesajı', a.yearMessage, fontBold, font),
                _section('Yaşam Dersi', a.lifeLesson, fontBold, font),
                _section(
                    'Genel Değerlendirme', a.overallSummary, fontBold, font),
                _footer(font),
              ],
            ),
          ),
        ],
      ),
    );

    final name =
        '${a.firstName}_${a.secondName}'.toLowerCase().replaceAll(' ', '_');
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
                    font: cinzelBold,
                    fontSize: 22,
                    color: _gold,
                    letterSpacing: 3)),
            pw.SizedBox(height: 2),
            pw.Text('Numeroloji Temelli Kişisel Farkındalık',
                style:
                    pw.TextStyle(font: cinzel, fontSize: 9, color: _textMuted)),
          ],
        ),
        pw.Container(
          width: 42,
          height: 42,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: _gold,
          ),
          alignment: pw.Alignment.center,
          child: pw.Text('*',
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
            style:
                pw.TextStyle(font: font, fontSize: 12, color: _textSecondary)),
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
    String name1,
    List<int> pin1,
    String name2,
    List<int> pin2,
    String relType,
    pw.Font cinzelBold,
    pw.Font font, {
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
                      style: pw.TextStyle(
                          font: cinzelBold, fontSize: 18, color: _gold)),
                  pw.Text(pin1.join('-'),
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: _textMuted,
                          letterSpacing: 2)),
                ],
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _border),
                  borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Text('♥',
                  style: pw.TextStyle(
                      font: cinzelBold, fontSize: 14, color: _purple)),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(name2,
                      style: pw.TextStyle(
                          font: cinzelBold, fontSize: 18, color: _gold)),
                  pw.Text(pin2.join('-'),
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: _textMuted,
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

  static pw.Widget _pinCodeTree(
    List<int> pinCode,
    pw.Font font,
    pw.Font fontBold, {
    String title = 'PIN KODU',
  }) {
    const labels = [
      'Kişilik',
      'Sosyal Bilinç',
      'Küresel Bilinç',
      'Yaşam Döngüsü',
      'Ders',
      'İçsel Benlik',
      'İçsel Çocuk',
      'Ruh Duygusu',
      'Evren',
    ];
    const colors = [
      _gold,
      _purple,
      PdfColor.fromInt(0xFF60A5FA),
      PdfColor.fromInt(0xFF34D399),
      PdfColor.fromInt(0xFFF97316),
      PdfColor.fromInt(0xFFF472B6),
      PdfColor.fromInt(0xFFA78BFA),
      PdfColor.fromInt(0xFF38BDF8),
      _gold,
    ];

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _border, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                  color: _gold,
                  letterSpacing: 1.5)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: List.generate(
              5,
              (i) => pw.Expanded(
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(right: i == 4 ? 0 : 5),
                  child: _pinTreeBox(
                    hane: i + 1,
                    digit: pinCode[i],
                    label: labels[i],
                    color: colors[i],
                    font: font,
                    fontBold: fontBold,
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Row(
            children: [
              pw.Spacer(flex: 1),
              pw.Expanded(
                child: _pinTreeBox(
                  hane: 6,
                  digit: pinCode[5],
                  label: labels[5],
                  color: colors[5],
                  font: font,
                  fontBold: fontBold,
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: _pinTreeBox(
                  hane: 7,
                  digit: pinCode[6],
                  label: labels[6],
                  color: colors[6],
                  font: font,
                  fontBold: fontBold,
                ),
              ),
              pw.Spacer(flex: 2),
            ],
          ),
          pw.SizedBox(height: 7),
          pw.Row(
            children: [
              pw.Spacer(flex: 1),
              pw.Expanded(
                flex: 2,
                child: _pinTreeBox(
                  hane: 8,
                  digit: pinCode[7],
                  label: labels[7],
                  color: colors[7],
                  font: font,
                  fontBold: fontBold,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                flex: 2,
                child: _pinTreeBox(
                  hane: 9,
                  digit: pinCode[8],
                  label: labels[8],
                  color: colors[8],
                  font: font,
                  fontBold: fontBold,
                  special: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(pinCode.join(' - '),
                style: pw.TextStyle(
                    font: font, fontSize: 10, color: _textSecondary)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pinTreeBox({
    required int hane,
    required int digit,
    required String label,
    required PdfColor color,
    required pw.Font font,
    required pw.Font fontBold,
    bool special = false,
  }) {
    return pw.Container(
      height: 58,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: pw.BoxDecoration(
        color: special ? color.shade(0.13) : _bg,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: color.shade(special ? 0.8 : 0.55)),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('H$hane',
              style: pw.TextStyle(font: font, fontSize: 7, color: color)),
          pw.SizedBox(height: 2),
          pw.Text('$digit',
              style: pw.TextStyle(font: fontBold, fontSize: 18, color: color)),
          pw.SizedBox(height: 2),
          pw.Text(label,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style:
                  pw.TextStyle(font: font, fontSize: 7.5, color: _textPrimary)),
        ],
      ),
    );
  }

  static pw.Widget _elementPanel(
    ElementBalance balance,
    pw.Font fontBold,
    pw.Font font, {
    String title = 'Element Haritası',
  }) {
    final maxElement = [
      balance.air,
      balance.water,
      balance.fire,
      balance.earth,
      balance.balanceNine,
    ].reduce((a, b) => a > b ? a : b);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _gold.shade(0.35), width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(font: fontBold, fontSize: 12, color: _gold)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _elementBadge('Baskın', balance.dominantElement,
                  _pdfElementColor(balance.dominantElement), fontBold, font),
              pw.SizedBox(width: 8),
              _elementBadge('Zayıf', balance.weakestElement,
                  _pdfElementColor(balance.weakestElement), fontBold, font),
              pw.SizedBox(width: 8),
              _elementBadge('Enerji', balance.energyType,
                  _pdfEnergyColor(balance.energyType), fontBold, font),
            ],
          ),
          pw.SizedBox(height: 12),
          _elementBar('Hava', balance.air, maxElement, _pdfElementColor('Hava'),
              fontBold, font),
          _elementBar('Su', balance.water, maxElement, _pdfElementColor('Su'),
              fontBold, font),
          _elementBar('Ateş', balance.fire, maxElement,
              _pdfElementColor('Ateş'), fontBold, font),
          _elementBar('Toprak', balance.earth, maxElement,
              _pdfElementColor('Toprak'), fontBold, font),
          _elementBar('Denge / 9', balance.balanceNine, maxElement, _gold,
              fontBold, font),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _scoreBox('Baskın Enerji',
                    _formatScore(balance.dominantScore), _gold, fontBold, font),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _scoreBox(
                    'Edilgen Enerji',
                    _formatScore(balance.passiveScore),
                    _purple,
                    fontBold,
                    font),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _elementBadge(String label, String value, PdfColor color,
      pw.Font fontBold, pw.Font font) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: pw.BoxDecoration(
          color: _bg,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: color.shade(0.75), width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    font: fontBold, fontSize: 8, color: _textPrimary)),
            pw.SizedBox(height: 2),
            pw.Text(value,
                style:
                    pw.TextStyle(font: fontBold, fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _elementBar(String label, int value, int maxValue,
      PdfColor color, pw.Font fontBold, pw.Font font) {
    final ratio = maxValue == 0 ? 0.0 : value / maxValue;
    final filledSegments = (ratio * 10).ceil().clamp(1, 10);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 58,
            child: pw.Row(
              children: [
                pw.Container(
                  width: 6,
                  height: 6,
                  decoration: pw.BoxDecoration(
                    color: color,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Expanded(
                  child: pw.Text(label,
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 9, color: _textPrimary)),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              height: 9,
              child: pw.Row(
                children: List.generate(
                  10,
                  (index) => pw.Expanded(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.only(right: index == 9 ? 0 : 2),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: index < filledSegments ? color : _border,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text('$value',
              style: pw.TextStyle(
                  font: fontBold, fontSize: 10, color: _textPrimary)),
        ],
      ),
    );
  }

  static pw.Widget _scoreBox(String label, String value, PdfColor color,
      pw.Font fontBold, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color.shade(0.75), width: 0.8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: fontBold, fontSize: 9, color: _textPrimary)),
          pw.Text(value,
              style: pw.TextStyle(font: fontBold, fontSize: 12, color: color)),
        ],
      ),
    );
  }

  static PdfColor _pdfElementColor(String element) {
    switch (element) {
      case 'Hava':
        return const PdfColor.fromInt(0xFF7DD3FC);
      case 'Su':
        return const PdfColor.fromInt(0xFF22D3EE);
      case 'Ateş':
        return const PdfColor.fromInt(0xFFFF8A3D);
      case 'Toprak':
        return const PdfColor.fromInt(0xFF4ADE80);
      default:
        return _gold;
    }
  }

  static PdfColor _pdfEnergyColor(String energy) {
    switch (energy) {
      case 'Baskın':
        return _gold;
      case 'Edilgen':
        return const PdfColor.fromInt(0xFFC084FC);
      default:
        return const PdfColor.fromInt(0xFF60A5FA);
    }
  }

  static String _formatScore(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  static pw.Widget _section(
      String title, String content, pw.Font fontBold, pw.Font font) {
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
              border: pw.Border(left: pw.BorderSide(color: _gold, width: 3)),
            ),
            child: pw.Text(title,
                style:
                    pw.TextStyle(font: fontBold, fontSize: 11, color: _gold)),
          ),
          pw.SizedBox(height: 8),
          pw.Text(content,
              style: pw.TextStyle(
                  font: font,
                  fontSize: 10.5,
                  color: _textPrimary,
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
            width: 32,
            height: 32,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: _surface,
              border: pw.Border.all(color: _gold, width: 1),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text('$digit',
                style:
                    pw.TextStyle(font: fontBold, fontSize: 14, color: _gold)),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(label,
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 10, color: _goldLight)),
                pw.SizedBox(height: 4),
                pw.Text(content,
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: _textPrimary,
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
          style: pw.TextStyle(
              font: cinzelBold, fontSize: 11, color: _gold, letterSpacing: 1)),
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
                  style:
                      pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
              pw.Text(
                  'Bu rapor numeroloji temelli kişisel farkındalık amacıyla hazırlanmıştır.',
                  style:
                      pw.TextStyle(font: font, fontSize: 7, color: _textMuted)),
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
    await _shareBytes(
      await file.readAsBytes(),
      filename: file.path.split('/').last,
      subject: subject,
    );
  }

  static Future<bool> _shareBytes(
    Uint8List bytes, {
    required String filename,
    String? subject,
  }) {
    return Printing.sharePdf(
      bytes: bytes,
      filename: filename,
      subject: subject,
    );
  }
}
