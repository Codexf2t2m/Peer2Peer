
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/wallet_command_view_model.dart';
import '../../../../shared/utils/formatters.dart';

class TransferDialog extends ConsumerStatefulWidget {
  const TransferDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TransferDialog(),
    );
  }

  @override
  ConsumerState<TransferDialog> createState() =>
      _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<TransferDialog> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController(text: '100');

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    ref.read(walletCommandViewModelProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commandState = ref.watch(walletCommandViewModelProvider);
    final isLoading = commandState.isLoading;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Transfer from wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _recipientController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Recipient',
              hintText: 'Name or mobile number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'P ',
              border: OutlineInputBorder(),
            ),
          ),
          if (commandState.hasError) ...[
            const SizedBox(height: 8),
            Text(
              commandState.errorMessage ?? '',
              style: const TextStyle(
                  color: Color(0xFFDC2626), fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Transfer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final amount =
        double.tryParse(_amountController.text.trim()) ?? 0;
    final recipient = _recipientController.text.trim();

    final success = await ref
        .read(walletCommandViewModelProvider.notifier)
        .transfer(amount, recipient);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Successfully transferred ${formatPula(amount)} to $recipient.'),
        ),
      );
    }
  }
}