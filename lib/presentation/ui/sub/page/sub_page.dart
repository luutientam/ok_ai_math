import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubPage extends StatefulWidget {
  const SubPage({super.key});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscription')),
      body: BlocConsumer<IAPBloc, IAPState>(
        listener: (context, state) {
          // Handle state changes with user feedback
          if (state is IAPErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is IAPPurchaseCompletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Purchase completed: ${state.purchase.productID}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is IAPRestoreCompletedState) {
            final restoredCount = state.restoredPurchases.length;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  restoredCount > 0
                      ? 'Restored $restoredCount purchase(s)'
                      : 'No purchases to restore',
                ),
                backgroundColor: restoredCount > 0
                    ? Colors.green
                    : Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                _buildStatusCard(state),
                const SizedBox(height: 16),

                // Loading Indicator
                if (state is IAPLoadingState ||
                    state is IAPPurchasingState ||
                    state is IAPRestoringState)
                  const Center(child: CircularProgressIndicator()),

                // Products List
                if (state is IAPProductsLoadedState)
                  _buildProductsList(context, state),

                // Purchases Info
                if (state is IAPPurchasesUpdatedState)
                  _buildPurchasesInfo(state),

                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(IAPState state) {
    final hasPremium = IAPHelper.hasPremiumAccess();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<ConfigSubBloc, ConfigSubState>(
              builder: (context, state) {
                if (state is ConfigSubLoaded) {
                  return Row(
                    children: [
                      Text(
                        'Sub: ${state.subConfig.isSub}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Lifetime: ${state.subConfig.isLifetime}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Remove Ad: ${state.subConfig.isRemoveAd}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    IAPProductsLoadedState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // ...state.products.map(
        //   (product) => Card(
        //     child: InkWell(
        //       onTap: () => _purchaseProduct(context, product),
        //       child: Column(
        //         children: [
        //           ListTile(
        //             title: Text(product.title),
        //             subtitle: Text(product.description),
        //             trailing: Text(product.price),
        //           ),
        //           Text('id: ${product.id}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //           const SizedBox(height: 8),
        //           Text('Product: ${product.title}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //           const SizedBox(height: 8),
        //           Text('Currency: ${product.currencyCode}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //           const SizedBox(height: 8),
        //           Text('Price: ${product.price}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //           const SizedBox(height: 8),
        //           Text('Description: ${product.description}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //           const SizedBox(height: 8),
        //           Text('Title: ${product.title}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //           const SizedBox(height: 8),
        //           Text('Currency Symbol: ${product.currencySymbol}', style: TextStyle(fontSize: 12, color: Colors.grey)),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPurchasesInfo(IAPPurchasesUpdatedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purchase Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (state.pendingPurchases.isNotEmpty) ...[
          Text('Pending Purchases: ${state.pendingPurchases.length}'),
          ...state.pendingPurchases.map(
            (p) => ListTile(
              leading: const Icon(Icons.hourglass_empty),
              title: Text(p.productID),
              subtitle: const Text('Pending...'),
            ),
          ),
        ],

        if (state.failedPurchases.isNotEmpty) ...[
          Text('Failed Purchases: ${state.failedPurchases.length}'),
          ...state.failedPurchases.map(
            (p) => ListTile(
              leading: const Icon(Icons.error),
              title: Text(p.productID),
              subtitle: Text('Error: ${p.error}'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, IAPState state) {
    // Get bloc reference to avoid context issues
    final iapBloc = context.read<IAPBloc>();

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            iapBloc.add(const IAPRestorePurchasesEvent());
          },
          child: const Text('Restore Purchases'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            iapBloc.add(const IAPClearCacheEvent());
          },
          child: const Text('Clear Cache'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // iapBloc.add(IAPLoadProductsEvent(IAPHelper.allProductIds));
          },
          child: const Text('Reload Products'),
        ),
      ],
    );
  }

  void _purchaseProduct(BuildContext context, product) {
    // All products are treated as non-consumable (premium products only)
    const isConsumable = false;

    // Get the bloc reference before showing dialog
    final iapBloc = context.read<IAPBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Purchase ${product.title}'),
        content: Text(
          'Are you sure you want to purchase ${product.title} for ${product.price}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use the bloc reference instead of context.read
              iapBloc.add(
                IAPPurchaseProductEvent(
                  product: product,
                  isConsumable: isConsumable,
                ),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}
