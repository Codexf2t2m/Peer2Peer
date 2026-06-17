
// UC: Request Community Loan + Request Direct Loan
//
// Architecture
// ────────────
// • ConsumerStatefulWidget — local state is limited to the four
//   TextEditingControllers and the parsed form values used by
//   RequestSummaryCard (which updates live as the user types).
// • Watches [requestViewModelProvider] for submission state.
// • On RequestSuccess, pops and shows a SnackBar via the caller's context.
// • ref.listen handles the success/error side-effects so build()
//   stays a pure render function.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../../ui/widgets/app_back_button.dart';
import '../view_models/request_view_model.dart';
import 'request_summary_card.dart';
import 'request_type_toggle.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _amountCtrl =
      TextEditingController(text: '500');
  final _interestCtrl = TextEditingController(
      text: defaultInterestRate.toStringAsFixed(0));
  final _durationCtrl = TextEditingController(
      text: defaultDurationDays.toString());
  final _noteCtrl = TextEditingController();
  final _lenderCtrl = TextEditingController();

  String _requestType = 'community';

  // Parsed values for the live summary card.
  double _parsedAmount = 500;
  double _parsedInterest = defaultInterestRate;
  int _parsedDuration = defaultDurationDays;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(_updateSummary);
    _interestCtrl.addListener(_updateSummary);
    _durationCtrl.addListener(_updateSummary);
  }

  void _updateSummary() {
    setState(() {
      _parsedAmount =
          double.tryParse(_amountCtrl.text.trim()) ?? 0;
      _parsedInterest =
          double.tryParse(_interestCtrl.text.trim()) ??
              defaultInterestRate;
      _parsedDuration =
          int.tryParse(_durationCtrl.text.trim()) ??
              defaultDurationDays;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _interestCtrl.dispose();
    _durationCtrl.dispose();
    _noteCtrl.dispose();
    _lenderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(requestViewModelProvider.notifier)
        .submit(
          amount: _parsedAmount,
          interestRate: _parsedInterest,
          durationDays: _parsedDuration,
          requestType: _requestType,
          purpose: _noteCtrl.text.trim().isEmpty
              ? null
              : _noteCtrl.text.trim(),
          targetLenderId: _requestType == 'direct'
              ? _lenderCtrl.text.trim()
              : null,
        );

    if (!mounted) return;

    if (success) {
      final state =
          ref.read(requestViewModelProvider) as RequestSuccess;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request for ${_formatAmount(state.amount)} submitted successfully.',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  static String _formatAmount(double amount) =>
      'P ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(requestViewModelProvider);
    final isLoading = requestState.isLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
        titleSpacing: 16,
        title: Text(
          'Request a loan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Request type 
            AppCard(
              child: RequestTypeToggle(
                selectedType: _requestType,
                enabled: !isLoading,
                onChanged: (type) =>
                    setState(() => _requestType = type),
              ),
            ),

            const SizedBox(height: 12),

            // Loan terms 
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Text('Amount',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountCtrl,
                    enabled: !isLoading,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    decoration: const InputDecoration(
                      prefixText: 'P ',
                      hintText: '0',
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Interest rate + duration side by side
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Interest rate (%)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _interestCtrl,
                              enabled: !isLoading,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                          decimal: true),
                              decoration:
                                  const InputDecoration(
                                suffixText: '%',
                                hintText: '15',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Duration (days)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _durationCtrl,
                              enabled: !isLoading,
                              keyboardType:
                                  TextInputType.number,
                              decoration:
                                  const InputDecoration(
                                suffixText: 'days',
                                hintText: '30',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Purpose
                  Text('Purpose (optional)',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteCtrl,
                    enabled: !isLoading,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'What is this loan for? A clear purpose builds lender confidence.',
                    ),
                  ),

                  // Direct lender field — shown only for direct requests
                  if (_requestType == 'direct') ...[
                    const SizedBox(height: 14),
                    Text('Lender ID or username',
                        style:
                            Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lenderCtrl,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Enter the lender\'s ID',
                      ),
                    ),
                  ],

                  // Error message
                  if (requestState.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      requestState.errorMessage ?? '',
                      style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Live summary 
            RequestSummaryCard(
              amount: _parsedAmount,
              interestRate: _parsedInterest,
              durationDays: _parsedDuration,
            ),

            const SizedBox(height: 16),

            // Submit 
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white),
                    )
                  : Text(
                      _requestType == 'community'
                          ? 'Submit to community'
                          : 'Send direct request',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}