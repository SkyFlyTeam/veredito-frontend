import 'package:flutter/material.dart';
import '../../../../../../shared/widgets/search_input.dart';
import '../../../../../../core/theme/app_colors.dart';

class PetitionHistoryScreen extends StatefulWidget {
  const PetitionHistoryScreen({super.key});

  @override
  State<PetitionHistoryScreen> createState() => _PetitionHistoryScreenState();
}

class _PetitionHistoryScreenState extends State<PetitionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data
  final List<Map<String, String>> _allItems = [
    {'name': 'Petição 001 - João Silva', 'id': 'PET001'},
    {'name': 'Petição 002 - Maria Santos', 'id': 'PET002'},
    {'name': 'Petição 003 - Pedro Costa', 'id': 'PET003'},
    {'name': 'Petição 004 - Ana Ferreira', 'id': 'PET004'},
    {'name': 'Petição 005 - Carlos Mendes', 'id': 'PET005'},
  ];

  late List<Map<String, String>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems
          .where(
            (item) =>
                item['name']!.toLowerCase().contains(query) ||
                item['id']!.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchInput(
            controller: _searchController,
            hintText: 'Buscar',
            onClear: () {
              setState(() {
                _filteredItems = _allItems;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Resultados: ${_filteredItems.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, color: AppColors.purple300),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            item['id']!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.gray300),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}