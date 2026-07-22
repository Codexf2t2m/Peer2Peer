
// UC34 – Submit Complaint
//
// Architecture
// ────────────
// • ConsumerStatefulWidget — local state is only the two
//   TextEditingControllers, the FormKey, and the selected type.
//   The selected type is lifted to local state (not the VM) because it
//   drives only the grid's visual selection and is not a network concern.
//
// • Watches [complaintViewModelProvider] for submission state.
//
// • ref.listen handles the success transition so build() stays pure —
//   the screen body switches to ComplaintSuccessView when state is
//   ComplaintSuccess.
//
// • No Supabase imports, no session provider, no demo-mode branching —
//   all of that lives in the repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../ui/widgets/app_back_button.dart';
import '../../../../data/models/complaint_model.dart';
import 'complaint_success_view.dart';
import '../view_models/complaint_view_model.dart';
import 'complaint_type_grid.dart';

class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({super.key});

  @override
  ConsumerState<ComplaintScreen> createState() =>
      _ComplaintScreenState();
}

class _ComplaintScreenState
    extends ConsumerState<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _againstController = TextEditingController();

  ComplaintType _selectedType = ComplaintType.fraud;

  @override
  void dispose() {
    _descriptionController.dispose();
    _againstController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(complaintViewModelProvider.notifier).submit(
          type: _selectedType,
          description: _descriptionController.text,
          againstUserEmail: _againstController.text.trim().isEmpty
              ? null
              : _againstController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(complaintViewModelProvider);
    final isLoading = uiState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        title: const Text(
          'Submit a Complaint',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: uiState.isSuccess
          ? ComplaintSuccessView(
              onDismiss: () => Navigator.of(context).pop(),
            )
          : _buildForm(isLoading, uiState.errorMessage),
    );
  }

  Widget _buildForm(bool isLoading, String? errorMessage) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        children: [
          // Info banner 
          const _InfoBanner(),

          const SizedBox(height: 24),

          // Type selector 
          const Text(
            'What is this about?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          ComplaintTypeGrid(
            selectedType: _selectedType,
            enabled: !isLoading,
            onChanged: (type) =>
                setState(() => _selectedType = type),
          ),

          const SizedBox(height: 24),

          // Against user 
          const Text(
            'Against user (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _againstController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: "Other user's email address",
              prefixIcon: const Icon(
                Icons.person_search_outlined,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Description 
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descriptionController,
            enabled: !isLoading,
            maxLines: 5,
            maxLength: 1000,
            decoration: _inputDecoration(
              hint:
                  'Describe the issue in as much detail as possible…',
            ),
            validator: (v) {
              if (v == null || v.trim().length < 20) {
                return 'Please provide at least 20 characters.';
              }
              return null;
            },
          ),

          // Inline error 
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                  color: Color(0xFFDC2626), fontSize: 13),
            ),
          ],

          const SizedBox(height: 28),

          // Submit 
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0038FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white),
                    )
                  : const Text(
                      'Submit Complaint',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration({
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF0038FF), width: 1.5),
      ),
    );
  }
}

// Info banner 

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline,
              color: Color(0xFFEA580C), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'All complaints are reviewed within 5 business days. '
              'False reports may result in account suspension.',
              style: TextStyle(
                  fontSize: 12, color: Color(0xFFEA580C)),
            ),
          ),
        ],
      ),
    );
  }
}