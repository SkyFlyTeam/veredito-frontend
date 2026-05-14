import 'package:flutter/material.dart';

class PetitionHistoryScreen extends StatelessWidget {
  const PetitionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// import 'package:flutter/material.dart';

// import '../../../../../core/theme/app_colors.dart';
// import '../../widgets/history_card.dart';

// class PetitionHistoryScreen extends StatelessWidget {
//   const PetitionHistoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hoje
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                 child: Text(
//                   'Hoje',
//                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                     color: Colors.white,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               HistoryCard(
//                 id: 1,
//                 name: 'Petição 34.pdf',
//                 createdAt: DateTime(2026, 5, 14, 8, 10),
//                 type: 'Petição',
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Status'),
//                       content: const Text('Estou funcionando'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               // Ontem
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                 child: Text(
//                   'Ontem',
//                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                     color: Colors.white,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               HistoryCard(
//                 id: 2,
//                 name: 'Petição 2',
//                 createdAt: DateTime(2026, 5, 13, 10, 20),
//                 type: 'Petição',
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Status'),
//                       content: const Text('Estou funcionando'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               HistoryCard(
//                 id: 3,
//                 name: 'Processo 1',
//                 createdAt: DateTime(2026, 5, 13, 15, 45),
//                 type: 'Processo',
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Status'),
//                       content: const Text('Estou funcionando'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               // 14/03
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                 child: Text(
//                   '14/03',
//                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                     color: Colors.white,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               HistoryCard(
//                 id: 4,
//                 name: 'Petição 3',
//                 createdAt: DateTime(2026, 3, 14, 14, 30),
//                 type: 'Petição',
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Status'),
//                       content: const Text('Estou funcionando'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
