import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final bool isHorizontal;
  final double? iconHeight;

  const AppLogo({super.key, required this.isHorizontal, this.iconHeight});

  @override
  Widget build(BuildContext context) {
    final double svgHeight = iconHeight ?? 80;
    final double fontSize = iconHeight != null ? iconHeight! * 0.75 : 28;

    return Container(
      child: isHorizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: iconHeight != null ? 6 : 10,
              children: [
                SvgPicture.asset(
                  'assets/logos/PurpleLogo.svg',
                  height: svgHeight,
                ),
                Text(
                  'Veredito',
                  style: TextStyle(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purple200,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                SvgPicture.asset('assets/logos/PurpleLogo.svg', width: 160),
                Text(
                  'Veredito',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    color: AppColors.purple200,
                  ),
                ),
              ],
            ),
    );
  }
}
