import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../providers/analysis_precedent_view_model_provider.dart';
import '../widget/PrecedentSuggestedCard.dart';
import '../widget/analysis_file_skeleton.dart';
import '../widget/analysis_section_title.dart';
import '../widget/petition_summary_skeleton.dart';
import '../widget/suggestion_cards_skeleton.dart';
import '../widget/suggestion_limit_dropdown.dart';
import '../view_models/analysis_precedent_state.dart';

class AnalysisPrecedentScreen extends ConsumerStatefulWidget {
  final Peticao? petition;

  const AnalysisPrecedentScreen({super.key, this.petition});

  @override
  ConsumerState<AnalysisPrecedentScreen> createState() =>
      _AnalysisPrecedentScreenState();
}

class _AnalysisPrecedentScreenState
    extends ConsumerState<AnalysisPrecedentScreen> {
  late final AnalysisPrecedentState _initialState;

  @override
  void initState() {
    super.initState();
    _initialState = AnalysisPrecedentState.initial(petition: widget.petition);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analysisPrecedentViewModelProvider(_initialState).notifier)
          .initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const suggestionLimitOptions = [1, 5, 10];
    final state = ref.watch(analysisPrecedentViewModelProvider(_initialState));
    final viewModel = ref.read(
      analysisPrecedentViewModelProvider(_initialState).notifier,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisSectionTitle(
            title: 'Analisando Arquivo',
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          if (state.isFileLoading)
            const AnalysisFileSkeleton()
          else
            GlassCard(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_rounded,
                      size: 34,
                      color: AppColors.gray100,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        state.documentDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray100,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          // if (state.isSummaryLoading) ...[
          //   AnalysisSectionTitle(
          //     title: 'Síntese da Petição',
          //     textTheme: textTheme,
          //   ),
          //   const SizedBox(height: 12),
          //   const PetitionSummarySkeleton(),
          //   const SizedBox(height: 28),
          // ] else if (state.petitionSummary != null) ...[
          //   AnalysisSectionTitle(
          //     title: 'Síntese da Petição',
          //     textTheme: textTheme,
          //   ),
          //   const SizedBox(height: 12),
          //   GlassCard(
          //     width: double.infinity,
          //     child: Padding(
          //       padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          //       child: Text(
          //         state.petitionSummary!,
          //         style: textTheme.bodyMedium?.copyWith(
          //           color: AppColors.gray100,
          //           fontSize: 12,
          //           fontWeight: FontWeight.w400,
          //           letterSpacing: 0,
          //         ),
          //       ),
          //     ),
          //   ),
          //   const SizedBox(height: 28),
          // ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnalysisSectionTitle(
                  title: 'Precedentes Sugeridos',
                  textTheme: textTheme,
                ),
              ),
              SuggestionLimitDropdown(
                value: state.selectedLimit,
                options: suggestionLimitOptions,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  viewModel.setSelectedLimit(value);
                },
              ),
              // const SizedBox(width: 8),
              // const HeaderActionButton(icon: Icons.info_outline_rounded),
              // const SizedBox(width: 8),
              // const HeaderActionButton(icon: Icons.sort_rounded),
              // const SizedBox(width: 8),
              // const HeaderActionButton(icon: Icons.filter_alt_outlined),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isSuggestionsLoading)
            const SuggestionCardsSkeleton()
          else if (state.visibleSuggestions.isEmpty)
            GlassCard(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Text(
                  'Nenhum precedente sugerido no momento.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray100,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                for (
                  var index = 0;
                  index < state.visibleSuggestions.length;
                  index++
                )
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == state.visibleSuggestions.length - 1
                          ? 0
                          : 12,
                    ),
                    child: PrecedentSuggestedCard(
                      suggestedPrecedent: state.visibleSuggestions[index],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
