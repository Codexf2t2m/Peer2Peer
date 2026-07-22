
import 'package:flutter/material.dart';

class KutloInputBar extends StatelessWidget {
  const KutloInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                minLines: 1,
                enabled: !isSending,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ask Kutlo anything…',
                  hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF), fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 44,
              child: FilledButton(
                onPressed: isSending ? null : onSend,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}