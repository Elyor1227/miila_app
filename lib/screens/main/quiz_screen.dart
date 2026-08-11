import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class QuizQuestion {
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Hozircha statik savollar banki — keyinroq backend /quiz API'ga ulanadi
const _defaultQuestions = [
  QuizQuestion(
    topic: 'SIKL ASOSLARI',
    question: 'Normal hayz sikli odatda necha kun davom etadi?',
    options: ['10–15 kun', '21–35 kun', '40–50 kun', '55–60 kun'],
    correctIndex: 1,
    explanation:
        'Normal sikl 21–35 kun oralig\'ida bo\'ladi. Muntazam ravishda bundan tashqariga chiqsa, shifokorga murojaat qilish tavsiya etiladi.',
  ),
  QuizQuestion(
    topic: 'HAYZ DAVRI',
    question: 'Hayz odatda necha kun davom etadi?',
    options: ['1–2 kun', '3–7 kun', '10–12 kun', '14 kundan ko\'p'],
    correctIndex: 1,
    explanation: 'Hayz odatda 3–7 kun davom etadi. 7 kundan uzoq davom etsa, shifokor bilan maslahatlashing.',
  ),
  QuizQuestion(
    topic: 'ANEMIYA',
    question: 'Quyidagilardan qaysi biri anemiya belgisi EMAS?',
    options: ['Doimiy charchoq', 'Bosh aylanishi', 'Energiya ko\'payishi', 'Terining oqarishi'],
    correctIndex: 2,
    explanation:
        'Energiya ko\'payishi anemiya belgisi emas. Asosiy belgilar: charchoq, bosh aylanishi, terining oqarishi va nafas qisilishi.',
  ),
  QuizQuestion(
    topic: 'OVULYATSIYA',
    question: 'Ovulyatsiya odatda siklning qaysi davrida sodir bo\'ladi?',
    options: ['Boshida', 'O\'rtasida', 'Oxirida', 'Hayz paytida'],
    correctIndex: 1,
    explanation:
        'Ovulyatsiya odatda sikl o\'rtasida — keyingi hayzdan taxminan 14 kun oldin sodir bo\'ladi.',
  ),
  QuizQuestion(
    topic: 'GIGIYENA',
    question: 'Hayz davrida gigiyena vositasini necha soatda almashtirish tavsiya etiladi?',
    options: ['Har 12 soatda', 'Har 4–6 soatda', 'Kuniga 1 marta', 'Faqat ertalab'],
    correctIndex: 1,
    explanation:
        'Gigiyena vositalarini har 4–6 soatda almashtirish infeksiya xavfini kamaytiradi.',
  ),
];

/// M-06 → M-07 → M-08 — Bilim testi oqimi (intro → savollar → natija)
class QuizScreen extends StatefulWidget {
  final String courseTitle;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    this.courseTitle = 'Hayz sikli asoslari',
    this.questions = _defaultQuestions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

enum _Stage { intro, question, result }

class _QuizScreenState extends State<QuizScreen> {
  _Stage _stage = _Stage.intro;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  late final List<bool> _results = List.filled(widget.questions.length, false);

  static const _pointsPerQuiz = 40;

  void _selectOption(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      _results[_index] = i == widget.questions[_index].correctIndex;
    });
  }

  void _next() {
    if (_index < widget.questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    } else {
      setState(() => _stage = _Stage.result);
    }
  }

  void _restart() {
    setState(() {
      _stage = _Stage.intro;
      _index = 0;
      _selected = null;
      _answered = false;
      for (var i = 0; i < _results.length; i++) {
        _results[i] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SafeArea(
        child: switch (_stage) {
          _Stage.intro => _buildIntro(),
          _Stage.question => _buildQuestion(),
          _Stage.result => _buildResult(),
        },
      ),
    );
  }

  // ── M-06 Quiz boshlash ──

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _closeButton(),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.question_mark_rounded, color: Colors.white, size: 46),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('Bilim testi', style: AppTextStyles.h1)),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.luteal.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⏱ ${widget.courseTitle}',
                style: AppTextStyles.caption.copyWith(color: AppColors.deep),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Darslardan o\'rganganlaringizni sinab ko\'ring',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _statCard(Icons.list_alt_rounded, '${widget.questions.length}', 'savol'),
              const SizedBox(width: 10),
              _statCard(Icons.schedule_rounded, '3', 'daqiqa'),
              const SizedBox(width: 10),
              _statCard(Icons.star_outline_rounded, '+$_pointsPerQuiz', 'ball'),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Testni boshlash',
            onPressed: () => setState(() => _stage = _Stage.question),
          ),
        ],
      ),
    );
  }

  // ── M-07 Quiz savoli ──

  Widget _buildQuestion() {
    final q = widget.questions[_index];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _closeButton(),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: List.generate(widget.questions.length, (i) {
                    return Expanded(
                      child: Container(
                        height: 5,
                        margin: EdgeInsets.only(right: i < widget.questions.length - 1 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i <= _index ? AppColors.pink : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_index + 1}/${widget.questions.length}', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 24),
          Text('${q.topic} · ${_index + 1}-SAVOL',
              style: AppTextStyles.label.copyWith(color: AppColors.pink)),
          const SizedBox(height: 8),
          Text(q.question, style: AppTextStyles.h3),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < q.options.length; i++) _option(q, i),
                if (_answered) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6DC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TUSHUNTIRISH',
                            style: AppTextStyles.label.copyWith(color: AppColors.gold)),
                        const SizedBox(height: 6),
                        Text(q.explanation, style: AppTextStyles.body.copyWith(height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          PrimaryButton(
            label: _index < widget.questions.length - 1 ? 'Keyingi savol' : 'Natijani ko\'rish',
            onPressed: _answered ? _next : null,
          ),
        ],
      ),
    );
  }

  Widget _option(QuizQuestion q, int i) {
    final letters = ['A', 'B', 'C', 'D'];
    final isCorrect = i == q.correctIndex;
    final isSelected = i == _selected;

    Color border = AppColors.cardBorder;
    Color bg = AppColors.white;
    Widget lead = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.blush, shape: BoxShape.circle),
      child: Text(letters[i], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.deep)),
    );

    if (_answered && isCorrect) {
      border = AppColors.success;
      bg = const Color(0xFFEAF7EC);
      lead = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26);
    } else if (_answered && isSelected && !isCorrect) {
      border = AppColors.period;
      bg = const Color(0xFFFDEBEE);
      lead = const Icon(Icons.cancel_rounded, color: AppColors.period, size: 26);
    }

    return GestureDetector(
      onTap: () => _selectOption(i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          children: [
            lead,
            const SizedBox(width: 12),
            Expanded(child: Text(q.options[i], style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }

  // ── M-08 Quiz natija ──

  Widget _buildResult() {
    final correct = _results.where((r) => r).length;
    final total = widget.questions.length;
    final percent = (correct / total * 100).round();
    final earned = (correct / total * _pointsPerQuiz).round();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerRight, child: _closeButton()),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: correct / total,
                      strokeWidth: 10,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: const AlwaysStoppedAnimation(AppColors.pink),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$percent%', style: AppTextStyles.h1),
                      Text('$correct/$total to\'g\'ri', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              percent >= 80
                  ? 'Ajoyib natija!'
                  : percent >= 50
                      ? 'Yaxshi harakat!'
                      : 'Yana bir urinib ko\'ring',
              style: AppTextStyles.h2,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              percent >= 50
                  ? 'Bu mavzuni yaxshi o\'zlashtiribsiz. Shu zaylda davom eting!'
                  : 'Darslarni qayta ko\'rib chiqib, yana urinib ko\'ring',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statCard(Icons.check_circle_outline_rounded, '$correct', 'To\'g\'ri'),
              const SizedBox(width: 10),
              _statCard(Icons.highlight_off_rounded, '${total - correct}', 'Noto\'g\'ri'),
              const SizedBox(width: 10),
              _statCard(Icons.star_outline_rounded, '+$earned', 'Ball'),
            ],
          ),
          const SizedBox(height: 16),
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
                Text('Savollar bo\'yicha', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(total, (i) {
                    final ok = _results[i];
                    return Column(
                      children: [
                        Icon(
                          ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: ok ? AppColors.success : AppColors.period,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text('${i + 1}', style: AppTextStyles.caption),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Davom etish',
            showArrow: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _restart,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pink,
              side: const BorderSide(color: AppColors.pink),
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.pink),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.h3),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _closeButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.ink),
      ),
    );
  }
}
