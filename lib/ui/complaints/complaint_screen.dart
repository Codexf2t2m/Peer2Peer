import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/providers/session_provider.dart';
import '../../data/providers/supabase_providers.dart';
import '../../ui/widgets/app_back_button.dart';

/// UC34 – Submit Complaint
///
/// Allows any authenticated user to file a complaint. Inserts a row
/// into the `complaints` table; admin screens (UC38) handle resolution.
class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({super.key});

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends ConsumerState<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _againstController = TextEditingController();

  String _selectedType = 'fraud';
  bool _submitting = false;
  bool _submitted = false;

  static const _types = [
    _ComplaintType(value: 'fraud', label: 'Fraud / Scam', icon: Icons.warning_amber_outlined),
    _ComplaintType(value: 'harassment', label: 'Harassment', icon: Icons.block_outlined),
    _ComplaintType(value: 'non_repayment', label: 'Non-repayment', icon: Icons.money_off_outlined),
    _ComplaintType(value: 'impersonation', label: 'Impersonation', icon: Icons.person_off_outlined),
    _ComplaintType(value: 'platform_bug', label: 'App / Platform', icon: Icons.bug_report_outlined),
    _ComplaintType(value: 'other', label: 'Other', icon: Icons.more_horiz_outlined),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _againstController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final session = ref.read(sessionProvider);
      if (!session.supabaseEnabled || session.currentUserId == null) {
        // Demo mode — pretend it worked
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) setState(() { _submitting = false; _submitted = true; });
        return;
      }

      final db = ref.read(supabaseClientProvider);
      final uid = session.currentUserId!;

      await db.from('complaints').insert({
        'user_id': uid,
        'type': _selectedType,
        'status': 'open',
        'description': _descriptionController.text.trim(),
        if (_againstController.text.trim().isNotEmpty)
          'against_user_id': null, // In production, resolve email → UUID
      });

      if (mounted) setState(() { _submitting = false; _submitted = true; });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: ${e.message}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFEA580C), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All complaints are reviewed within 5 business days. '
                    'False reports may result in account suspension.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFEA580C)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Complaint type selector
          const Text(
            'What is this about?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: _types.map((t) {
              final selected = _selectedType == t.value;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = t.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEFF6FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF0038FF)
                          : const Color(0xFFE5E7EB),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t.icon,
                        size: 22,
                        color: selected
                            ? const Color(0xFF0038FF)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected
                              ? const Color(0xFF0038FF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Optional: against whom
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
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Other user's email address",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0038FF), width: 1.5),
              ),
              prefixIcon: const Icon(Icons.person_search_outlined,
                  color: Color(0xFF9CA3AF)),
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
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText:
                  'Describe the issue in as much detail as possible…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0038FF), width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().length < 20) {
                return 'Please provide at least 20 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0038FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Submit Complaint',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Success state ─────────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF059669), size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Complaint submitted',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our team will review your complaint within 5 business days '
              'and contact you via email with an update.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to app'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintType {
  final String value;
  final String label;
  final IconData icon;

  const _ComplaintType(
      {required this.value, required this.label, required this.icon});
}
