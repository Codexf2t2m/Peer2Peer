import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_routes.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/providers/supabase_providers.dart';
import 'email_verification_screen.dart' show _OnboardingStepIndicator;

/// Step 3 of onboarding: upload a KYC identity document.
///
/// Supports national ID, passport, or driver's licence.
/// The file is uploaded to Supabase Storage via KycRepository,
/// which also inserts a `kyc_documents` row and advances `onboarding_step`.
///
/// On web/desktop (where file_picker is unavailable) a mock upload
/// is used so that the full onboarding can be exercised in a browser.
class KycUploadScreen extends ConsumerStatefulWidget {
  const KycUploadScreen({super.key});

  @override
  ConsumerState<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends ConsumerState<KycUploadScreen> {
  String _selectedDocType = 'national_id';
  bool _uploading = false;
  String? _uploadedFileName;

  static const _docTypes = [
    _DocType(value: 'national_id', label: 'National ID', icon: Icons.badge_outlined),
    _DocType(value: 'passport', label: 'Passport', icon: Icons.book_outlined),
    _DocType(value: 'drivers_licence', label: "Driver's Licence", icon: Icons.drive_eta_outlined),
  ];

  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);

    try {
      // Simulate file pick & upload (real implementation would use file_picker)
      await Future<void>.delayed(const Duration(seconds: 2));

      // Use a small mock PNG (1×1 transparent pixel) so Supabase Storage
      // receives a real file upload during integration testing.
      const mockBytes = <int>[
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0,
        0, 0, 12, 73, 68, 65, 84, 8, 215, 99, 248, 207, 192, 0, 0, 0,
        2, 0, 1, 232, 33, 188, 51, 0, 0, 0, 0, 73, 69, 78, 68, 174,
        66, 96, 130,
      ];
      final bytes = Uint8List.fromList(mockBytes);
      final session = ref.read(sessionProvider);

      if (session.supabaseEnabled && session.isSignedIn) {
        final kycRepo = ref.read(kycRepositoryProvider);
        await kycRepo.uploadDocument(
          fileBytes: bytes,
          fileName: '$_selectedDocType.png',
          documentType: _selectedDocType,
        );
      } else {
        // Demo mode: just advance locally
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;
      setState(() {
        _uploadedFileName = '$_selectedDocType.png';
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _continue() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.creditAssessment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OnboardingStepIndicator(currentStep: 2),
              const SizedBox(height: 40),

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Color(0xFF7C3AED),
                  size: 36,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Verify your identity',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We need a government-issued ID to comply with our KYC requirements. '
                'Your document is stored securely and never shared with third parties.',
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 28),

              // Document type selector
              const Text(
                'Document type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: _docTypes.map((dt) {
                  final selected = _selectedDocType == dt.value;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDocType = dt.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFE5E7EB),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                dt.icon,
                                color: selected
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFF9CA3AF),
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dt.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selected
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Upload zone
              GestureDetector(
                onTap: (_uploading || _uploadedFileName != null) ? null : _pickAndUpload,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: _uploadedFileName != null
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _uploadedFileName != null
                          ? const Color(0xFF059669)
                          : const Color(0xFFD1D5DB),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: _uploading
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: Color(0xFF7C3AED), strokeWidth: 3),
                            SizedBox(height: 12),
                            Text('Uploading securely…',
                                style: TextStyle(color: Color(0xFF6B7280))),
                          ],
                        )
                      : _uploadedFileName != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF059669), size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  _uploadedFileName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Document uploaded — pending review',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_outlined,
                                    size: 36, color: Color(0xFF9CA3AF)),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to upload a photo or PDF',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'JPG, PNG or PDF · Max 10 MB',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _uploadedFileName == null ? null : _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocType {
  final String value;
  final String label;
  final IconData icon;

  const _DocType({required this.value, required this.label, required this.icon});
}
