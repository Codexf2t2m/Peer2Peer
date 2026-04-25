import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../ui/widgets/app_back_button.dart';

class AskKutloScreen extends StatefulWidget {
  const AskKutloScreen({super.key});

  @override
  State<AskKutloScreen> createState() => _AskKutloScreenState();
}

class _AskKutloScreenState extends State<AskKutloScreen> {
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ask'),
            ),
            if (_response != null) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kutlo says',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(_response!),
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
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
