import 'package:flutter/material.dart';

import '../../services/tracker_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// M-11 — Belgi kiritish (real POST /tracker/symptoms'ga ulangan)
class SymptomEntryScreen extends StatefulWidget {
  const SymptomEntryScreen({super.key});

  @override
  State<SymptomEntryScreen> createState() => _SymptomEntryScreenState();
}

class _SymptomEntryScreenState extends State<SymptomEntryScreen> {
  final _trackerService = TrackerService();
  final _notesController = TextEditingController();

  final Set<String> _bodyParts = {};
  int _painIndex = 1; // 0 yengil, 1 o'rta, 2 kuchli
  int _moodIndex = 2;
  int _flowIndex = 2; // none, light, medium, heavy
  final Set<String> _otherSymptoms = {};

  static const _bodyPartOptions = ['Bosh', 'Ko\'krak', 'Qorin', 'Bel', 'Oyoq'];
  static const _painLabels = ['Yengil', 'O\'rta', 'Kuchli'];
  static const _painValues = [2, 5, 8];
  static const _moods = [
    ('😍', 'Zo\'r', 'happy'),
    ('🙂', 'Yaxshi', 'happy'),
    ('😐', 'O\'rtacha', 'neutral'),
    ('😔', 'Charchoq', 'tired'),
    ('😣', 'Yomon', 'sad'),
  ];
  static const _flows = [
    ('Yo\'q', 'none'),
    ('Kam', 'light'),
    ('O\'rta', 'medium'),
    ('Ko\'p', 'heavy'),
  ];
  static const _otherOptions = [
    'Charchoq',
    'Ko\'ngil aynishi',
    'Bosh aylanishi',
    'Ishtaha ortishi',
    'Uyqusizlik',
    'Teri toshmasi',
  ];

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _trackerService.addSymptoms(
        date: DateTime.now(),
        items: _otherSymptoms.toList(),
        mood: _moods[_moodIndex].$3,
        painLevel: _painValues[_painIndex],
        flowLevel: _flows[_flowIndex].$2,
        bodyParts: _bodyParts.map((p) => p.toLowerCase()).toList(),
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belgilar saqlandi ✓')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Bugungi belgilar', style: AppTextStyles.h4)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(
                title: 'Qayeringiz bezovta qilyapti?',
                subtitle: 'Tanada bosib belgilang',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _bodyPartOptions.map((p) {
                    final selected = _bodyParts.contains(p);
                    return _chip(p, selected, () {
                      setState(() => selected ? _bodyParts.remove(p) : _bodyParts.add(p));
                    });
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _card(
                title: 'Og\'riq kuchi',
                child: Row(
                  children: List.generate(_painLabels.length, (i) {
                    final selected = i == _painIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _painIndex = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.pink : AppColors.blush,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _painLabels[i],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: selected ? Colors.white : AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              _card(
                title: 'Kayfiyating qanday?',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_moods.length, (i) {
                    final selected = i == _moodIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _moodIndex = i),
                      child: Column(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.pink.withOpacity(0.12) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: selected ? Border.all(color: AppColors.pink, width: 1.6) : null,
                            ),
                            child: Text(_moods[i].$1, style: const TextStyle(fontSize: 21)),
                          ),
                          const SizedBox(height: 4),
                          Text(_moods[i].$2, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              _card(
                title: 'Oqim darajasi',
                child: Row(
                  children: List.generate(_flows.length, (i) {
                    final selected = i == _flowIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _flowIndex = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < _flows.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.period : AppColors.blush,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  i == 0 ? 1 : i,
                                  (_) => Icon(
                                    i == 0 ? Icons.close_rounded : Icons.circle,
                                    size: i == 0 ? 12 : 6,
                                    color: selected ? Colors.white : AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _flows[i].$1,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  color: selected ? Colors.white : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              _card(
                title: 'Boshqa belgilar',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _otherOptions.map((s) {
                    final selected = _otherSymptoms.contains(s);
                    return _chip(s, selected, () {
                      setState(() => selected ? _otherSymptoms.remove(s) : _otherSymptoms.add(s));
                    });
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _card(
                title: 'Izoh',
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Yozuvni tavsirlash...',
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              PrimaryButton(label: 'Saqlash', showArrow: false, isLoading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.pink : AppColors.blush,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
