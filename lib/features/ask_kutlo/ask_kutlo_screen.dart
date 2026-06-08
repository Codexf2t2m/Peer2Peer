import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../ui/widgets/app_back_button.dart';

class AskKutloScreen extends ConsumerStatefulWidget {
  const AskKutloScreen({super.key});

  @override
  ConsumerState<AskKutloScreen> createState() => _AskKutloScreenState();
}

class _AskKutloScreenState extends ConsumerState<AskKutloScreen> {
  final _ctrl = TextEditingController();
  String? _response;
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _ctrl.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a question for Kutlo.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _response = DemoStore.instance.buildKutloReply(question);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop() ? const AppBackButton() : null,
        titleSpacing: 16,
        title: Text('Ask Kutlo', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can I help?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ctrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'e.g. “How much can I safely lend this month?”',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SuggestionChip(
                        label: 'Should I lend P600?',
                        onTap: () => _ctrl.text = 'Should I lend P600 this week?',
                      ),
                      _SuggestionChip(
                        label: 'How do I write a strong request?',
                        onTap: () => _ctrl.text = 'How do I write a strong request?',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _ask,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Ask'),
            ),
            if (_response != null) ...[
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Color(0xFF0038FF), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Kutlo Advice',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _response!,
                      style: const TextStyle(height: 1.4, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      backgroundColor: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
