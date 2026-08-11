import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// M-24 (savol yuborish) — Savol-javob (real /qna'ga ulangan)
class QnaScreen extends StatefulWidget {
  const QnaScreen({super.key});

  @override
  State<QnaScreen> createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  final _api = ApiClient.instance;
  final _questionController = TextEditingController();
  List<Map<String, dynamic>> _myAnswers = const [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _api.get('/qna/answers');
      if (!mounted) return;
      setState(() {
        _myAnswers = (data['items'] as List? ?? []).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final question = _questionController.text.trim();
    if (question.length < 5) {
      setState(() => _error = 'Savol kamida 5 ta belgi bo\'lishi kerak');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await _api.post('/qna/questions', body: {'question': question});
      if (!mounted) return;
      _questionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savolingiz yuborildi! Tez orada javob beramiz.')),
      );
      _load();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Savol-javob', style: AppTextStyles.h4)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mutaxassisga savol bering', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Savolingiz anonim ko\'rib chiqiladi', style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Savolingiz',
                    hint: 'Savolingizni yozing...',
                    controller: _questionController,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
                  ],
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Yuborish',
                    showArrow: false,
                    isLoading: _sending,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('MENING SAVOLLARIM', style: AppTextStyles.label),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator(color: AppColors.pink)),
              )
            else if (_myAnswers.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text('Hozircha javob berilgan savollaringiz yo\'q', style: AppTextStyles.caption),
              )
            else
              ..._myAnswers.map((q) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q['question']?.toString() ?? '', style: AppTextStyles.bodyMedium),
                        if ((q['answer']?.toString() ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blush,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(q['answer'].toString(), style: AppTextStyles.body),
                          ),
                        ],
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
