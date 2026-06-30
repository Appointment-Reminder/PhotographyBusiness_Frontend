import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';

class WebhookUrlRow extends StatefulWidget {
  final String url;
  const WebhookUrlRow({super.key, required this.url});

  @override
  State<WebhookUrlRow> createState() => _WebhookUrlRowState();
}

class _WebhookUrlRowState extends State<WebhookUrlRow> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, size: 14, color: AppColors.mutedText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.url,
              style: AppTextStyles.mono11.copyWith(color: AppColors.primaryText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _copy,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    _copied ? Icons.check : Icons.copy,
                    key: ValueKey(_copied),
                    size: 13,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _copied ? 'Copied' : 'Copy',
                  style: AppTextStyles.mono11.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}