
// Extracted from the inline AnimatedContainer upload zone.

import 'package:flutter/material.dart';

class DocumentUploadZone extends StatelessWidget {
  const DocumentUploadZone({
    super.key,
    required this.isUploading,
    required this.uploadedFileName,
    required this.onTap,
  });

  final bool isUploading;
  final String? uploadedFileName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final uploaded = uploadedFileName != null;

    return GestureDetector(
      onTap: (isUploading || uploaded) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: uploaded
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF059669)
                : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: isUploading
            ? const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Color(0xFF7C3AED),
                      strokeWidth: 3),
                  SizedBox(height: 12),
                  Text('Uploading securely…',
                      style: TextStyle(
                          color: Color(0xFF6B7280))),
                ],
              )
            : uploaded
                ? Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF059669),
                          size: 36),
                      const SizedBox(height: 8),
                      Text(
                        uploadedFileName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Document uploaded — pending review',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file_outlined,
                          size: 36,
                          color: Color(0xFF9CA3AF)),
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
                            fontSize: 12,
                            color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
      ),
    );
  }
}