
// UC: Upload KYC Documents — Step 3 of onboarding.
//
// Architecture
// • ConsumerStatefulWidget — local state is ONLY _selectedDocType,
//   which drives the selector's visual highlight (not a network concern).
// • Mock file bytes generation stays here since it's a platform/file
//   concern, not business logic — in production this calls file_picker
//   and passes real bytes to the VM.
// • ref.listen could be used, but this screen reads uiState directly
//   since there's no cross-screen navigation side effect from upload
//   itself — Continue is a separate explicit user action.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app_routes.dart';
import '../../../../../data/models/kyc_document_model.dart';
import '../../widgets/onboarding_step_indicator.dart';
import '../view_models/kyc_upload_view_model.dart';
import 'document_type_selector.dart';
import 'document_upload_zone.dart';

class KycUploadScreen extends ConsumerStatefulWidget {
  const KycUploadScreen({super.key});

  @override
  ConsumerState<KycUploadScreen> createState() =>
      _KycUploadScreenState();
}

class _KycUploadScreenState
    extends ConsumerState<KycUploadScreen> {
  KycDocumentType _selectedType =
      KycDocumentType.nationalId;

  Future<void> _pickAndUpload() async {
    // Mock file bytes — a 1x1 transparent PNG.
    // In production, replace this with a real file_picker call.
    final mockBytes = Uint8List.fromList(const [
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73,
      72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0,
      144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 8,
      215, 99, 248, 207, 192, 0, 0, 0, 2, 0, 1, 232, 33,
      188, 51, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96,
      130,
    ]);

    await ref
        .read(kycUploadViewModelProvider.notifier)
        .upload(
          fileBytes: mockBytes,
          fileName: '${_selectedType.apiValue}.png',
          documentType: _selectedType,
        );
  }

  void _continue() {
    Navigator.of(context).pushReplacementNamed(
        AppRoutes.creditAssessment);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(kycUploadViewModelProvider, (_, next) {
      if (next is KycUploadError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Upload failed: ${next.message}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    });

    final uiState = ref.watch(kycUploadViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 2),
              const SizedBox(height: 40),

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED)
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(20),
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
                'We need a government-issued ID to comply with '
                'our KYC requirements. Your document is stored '
                'securely and never shared with third parties.',
                style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.5),
              ),
              const SizedBox(height: 28),

              const Text(
                'Document type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              DocumentTypeSelector(
                selected: _selectedType,
                onChanged: (type) =>
                    setState(() => _selectedType = type),
              ),

              const SizedBox(height: 28),

              DocumentUploadZone(
                isUploading: uiState.isLoading,
                uploadedFileName:
                    uiState.document?.documentType
                        .apiValue,
                onTap: _pickAndUpload,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: uiState.isSuccess
                      ? _continue
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF7C3AED),
                    disabledBackgroundColor:
                        const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
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