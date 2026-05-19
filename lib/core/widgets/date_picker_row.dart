import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class DatePickerRow extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onChanged;

  const DatePickerRow({
    super.key,
    this.initialDate,
    required this.onChanged,
  });

  @override
  State<DatePickerRow> createState() => _DatePickerRowState();
}

class _DatePickerRowState extends State<DatePickerRow> {
  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  int? _day;
  int? _month;
  int? _year;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _day = widget.initialDate!.day;
      _month = widget.initialDate!.month;
      _year = widget.initialDate!.year;
    }
  }

  void _notify() {
    if (_day != null && _month != null && _year != null) {
      final maxDay = _daysInMonth(_month!, _year!);
      final safeDay = _day! > maxDay ? maxDay : _day!;
      widget.onChanged(DateTime(_year!, _month!, safeDay));
    } else {
      widget.onChanged(null);
    }
  }

  int _daysInMonth(int month, int year) =>
      DateTime(year, month + 1, 0).day;

  List<int> get _dayList {
    final max = (_month != null && _year != null)
        ? _daysInMonth(_month!, _year!)
        : 31;
    return List.generate(max, (i) => i + 1);
  }

  List<int> get _yearList {
    final now = DateTime.now().year;
    return List.generate(now - 1899, (i) => now - i);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gün
        Expanded(
          flex: 2,
          child: _Dropdown<int>(
            hint: 'Gün',
            value: _day,
            items: _dayList,
            label: (d) => d.toString(),
            onChanged: (v) {
              setState(() => _day = v);
              _notify();
            },
          ),
        ),
        const SizedBox(width: 8),
        // Ay
        Expanded(
          flex: 3,
          child: _Dropdown<int>(
            hint: 'Ay',
            value: _month,
            items: List.generate(12, (i) => i + 1),
            label: (m) => _months[m - 1],
            onChanged: (v) {
              setState(() => _month = v);
              _notify();
            },
          ),
        ),
        const SizedBox(width: 8),
        // Yıl
        Expanded(
          flex: 3,
          child: _Dropdown<int>(
            hint: 'Yıl',
            value: _year,
            items: _yearList,
            label: (y) => y.toString(),
            onChanged: (v) {
              setState(() => _year = v);
              _notify();
            },
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceLight,
          style: AppTextStyles.bodyLarge,
          hint: Text(hint, style: AppTextStyles.bodyMedium),
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: AppColors.textMuted),
          menuMaxHeight: 260,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(label(item)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
