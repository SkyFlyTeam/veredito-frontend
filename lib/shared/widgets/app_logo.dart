import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final bool isHorizontal;

  const AppLogo({super.key, required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isHorizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                SvgPicture.asset('assets/logos/PurpleLogo.svg', width: 80),
                Text(
                  'Veredito',
                  style: TextStyle(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    fontSize: 28,
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
