
// UC: Upload KYC Documents

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/kyc_document_model.dart';
import '../../../../../data/providers/onboarding_providers.dart';

// State 

sealed class KycUploadState {
  const KycUploadState();
}

class KycUploadIdle extends KycUploadState {
  const KycUploadIdle();
}

class KycUploadLoading extends KycUploadState {
  const KycUploadLoading();
}

class KycUploadSuccess extends KycUploadState {
  const KycUploadSuccess(this.document);
  final KycDocumentModel document;
}

class KycUploadError extends KycUploadState {
  const KycUploadError(this.message);
  final String message;
}

extension KycUploadStateX on KycUploadState {
  bool get isLoading => this is KycUploadLoading;
  bool get isSuccess => this is KycUploadSuccess;
  KycDocumentModel? get document =>
      this is KycUploadSuccess
          ? (this as KycUploadSuccess).document
          : null;
  String? get errorMessage => this is KycUploadError
      ? (this as KycUploadError).message
      : null;
}

// ViewModel 

class KycUploadViewModel
    extends AutoDisposeNotifier<KycUploadState> {
  @override
  KycUploadState build() => const KycUploadIdle();

  Future<bool> upload({
    required Uint8List fileBytes,
    required String fileName,
    required KycDocumentType documentType,
  }) async {
    state = const KycUploadLoading();
    try {
      final doc = await ref
          .read(onboardingRepositoryProvider)
          .uploadKycDocument(
            fileBytes: fileBytes,
            fileName: fileName,
            documentType: documentType,
          );
      state = KycUploadSuccess(doc);
      return true;
    } catch (e) {
      state = KycUploadError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void reset() => state = const KycUploadIdle();
}

// Provider 

final kycUploadViewModelProvider = NotifierProvider.autoDispose<
    KycUploadViewModel, KycUploadState>(
  KycUploadViewModel.new,
);