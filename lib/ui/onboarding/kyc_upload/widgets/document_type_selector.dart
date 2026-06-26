
// Extracted from the inline Row of document type tiles.

import 'package:flutter/material.dart';

import '../../../../../data/models/kyc_document_model.dart';

class DocumentTypeSelector extends StatelessWidget {
  const DocumentTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final KycDocumentType selected;
  final ValueChanged<KycDocumentType> onChanged;

  static const _icons = {
    KycDocumentType.nationalId: Icons.badge_outlined,
    KycDocumentType.passport: Icons.book_outlined,
    KycDocumentType.driversLicence: Icons.drive_eta_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: KycDocumentType.values.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7C3AED)
                          .withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _icons[type],
                      color: isSelected
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF9CA3AF),
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
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
    );
  }
}