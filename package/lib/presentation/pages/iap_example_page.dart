// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:package/bloc/iap_bloc.dart';
// import 'package:package/core/iap_helper.dart';

// /// Example page showing how to use IAP BLoC in main app
// ///
// /// This demonstrates the complete integration of IAP functionality
// /// using the BLoC pattern and dependency injection
// class IAPExamplePage extends StatelessWidget {
//   const IAPExamplePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('In-App Purchase Example')),
//       body: BlocProvider(
//         create: (context) => IAPHelper.getIAPBloc()
//           ..add(const IAPInitializeEvent())
//           ..add(IAPLoadProductsEvent(IAPHelper.allProductIds)),
//         child: const _IAPContent(),
//       ),
//     );
//   }
// }

// class _IAPContent extends StatelessWidget {
//   const _IAPContent();

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<IAPBloc, IAPState>(
//       listener: (context, state) {
//         // Handle state changes with user feedback
//         if (state is IAPErrorState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
//           );
//         } else if (state is IAPPurchaseCompletedState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Purchase completed: ${state.purchase.productID}'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Status Card
//               _buildStatusCard(state),
//               const SizedBox(height: 16),

//               // Loading Indicator
//               if (state is IAPLoadingState ||
//                   state is IAPPurchasingState ||
//                   state is IAPRestoringState)
//                 const Center(child: CircularProgressIndicator()),

//               // Products List
//               if (state is IAPProductsLoadedState) _buildProductsList(context, state),

//               // Purchases Info
//               if (state is IAPPurchasesUpdatedState) _buildPurchasesInfo(state),

//               const SizedBox(height: 16),

//               // Action Buttons
//               _buildActionButtons(context, state),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusCard(IAPState state) {
//     final hasPremium = IAPHelper.hasPremiumAccess();
//     final coinBalance = IAPHelper.getCoinBalance();

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Account Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   hasPremium ? Icons.star : Icons.star_border,
//                   color: hasPremium ? Colors.amber : Colors.grey,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(hasPremium ? 'Premium User' : 'Free User'),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 const Icon(Icons.monetization_on, color: Colors.orange),
//                 const SizedBox(width: 8),
//                 Text('Coins: $coinBalance'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductsList(BuildContext context, IAPProductsLoadedState state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Available Products',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         ...state.products.map(
//           (product) => Card(
//             child: ListTile(
//               title: Text(product.title),
//               subtitle: Text(product.description),
//               trailing: Text(product.price),
//               onTap: () => _purchaseProduct(context, product),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPurchasesInfo(IAPPurchasesUpdatedState state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Purchase Information',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),

//         if (state.pendingPurchases.isNotEmpty) ...[
//           Text('Pending Purchases: ${state.pendingPurchases.length}'),
//           ...state.pendingPurchases.map(
//             (p) => ListTile(
//               leading: const Icon(Icons.hourglass_empty),
//               title: Text(p.productID),
//               subtitle: const Text('Pending...'),
//             ),
//           ),
//         ],

//         if (state.failedPurchases.isNotEmpty) ...[
//           Text('Failed Purchases: ${state.failedPurchases.length}'),
//           ...state.failedPurchases.map(
//             (p) => ListTile(
//               leading: const Icon(Icons.error),
//               title: Text(p.productID),
//               subtitle: Text('Error: ${p.error}'),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, IAPState state) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             context.read<IAPBloc>().add(const IAPRestorePurchasesEvent());
//           },
//           child: const Text('Restore Purchases'),
//         ),
//         const SizedBox(height: 8),
//         ElevatedButton(
//           onPressed: () {
//             context.read<IAPBloc>().add(const IAPClearCacheEvent());
//           },
//           child: const Text('Clear Cache'),
//         ),
//         const SizedBox(height: 8),
//         ElevatedButton(
//           onPressed: () {
//             context.read<IAPBloc>().add(IAPLoadProductsEvent(IAPHelper.allProductIds));
//           },
//           child: const Text('Reload Products'),
//         ),
//       ],
//     );
//   }

//   void _purchaseProduct(BuildContext context, product) {
//     // Determine if product is consumable based on product ID
//     final isConsumable = product.id.startsWith('coins_');

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Purchase ${product.title}'),
//         content: Text('Are you sure you want to purchase ${product.title} for ${product.price}?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<IAPBloc>().add(
//                 IAPPurchaseProductEvent(product: product, isConsumable: isConsumable),
//               );
//             },
//             child: const Text('Purchase'),
//           ),
//         ],
//       ),
//     );
//   }
// }
