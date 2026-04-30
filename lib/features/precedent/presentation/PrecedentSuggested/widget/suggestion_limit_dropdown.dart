import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class SuggestionLimitDropdown extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  const SuggestionLimitDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.gray900,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );

    return SizedBox(
      width: 58,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              itemHeight: 48,
              menuMaxHeight: 192,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.gray900,
              ),
              dropdownColor: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
              style: textStyle,
              items: options
                  .map(
                    (option) => DropdownMenuItem<int>(
                      value: option,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: option == value
                              ? AppColors.purple300.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text('$option', style: textStyle)),
                            if (option == value)
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.purple300,
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              selectedItemBuilder: (context) => options
                  .map(
                    (option) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$option',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
