import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryCard extends StatelessWidget {
  final int id;
  final String name;
  final DateTime createdAt;
  final String? type;
  final VoidCallback? onPressed;
  final IconData icon;

  const HistoryCard({
    super.key,
    required this.id,
    required this.name,
    required this.createdAt,
    this.type,
    this.onPressed,
    this.icon = Icons.description,
  });

  String _formatDate(DateTime date) {
    final timeFormatted =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return timeFormatted;
  }

  Color _getTypeColor() {
    if (type?.toLowerCase() == 'petição') {
      return AppColors.blue200;
    } else if (type?.toLowerCase() == 'processo') {
      return AppColors.green50;
    }
    return AppColors.blue200;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(77, 145, 141, 255),
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(
          //   color: AppColors.gray100.withValues(alpha: 0.2),
          //   width: 1.2,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        if (type != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11.3,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type!,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (type != null) const SizedBox(width: 6),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
