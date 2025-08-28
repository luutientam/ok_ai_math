import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class DemoSubPage extends StatefulWidget {
  const DemoSubPage({super.key});

  @override
  State<DemoSubPage> createState() => _DemoSubPageState();
}

class _DemoSubPageState extends State<DemoSubPage> {
  ProductDetails? weekly;
  ProductDetails? monthly;
  ProductDetails? yearly;
  ProductDetails? lifetime;

  @override
  Widget build(BuildContext context) {
    final iapBloc = context.read<IAPBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscription')),
      body: BlocListener<IAPBloc, IAPState>(
        listener: (context, state) {
          if (state is IAPErrorState) {
            // LoadingDialog.hide(context);
            iapBloc.add(IAPLoadProductsEvent(IAPHelper.allProductIds));
          }
          if (state is IAPPurchasesUpdatedState) {
            print('Purchases updated: ${state.purchases.length}');
            for (final purchase in state.purchases) {
              if (purchase.status == PurchaseStatus.purchased) {
                print('Purchase successful: ${purchase.productID}');
                // Navigator.of(context).pop();
              } else if (purchase.status == PurchaseStatus.restored) {
                LoadingDialog.hide(context);
                print(
                  'Purchase restored: productID ${purchase.productID}, verificationData ${purchase.verificationData.localVerificationData}, Transaction Date: ${purchase.transactionDate}, serverVerificationData ID: ${purchase.verificationData.serverVerificationData}',
                );
                // Handle restored purchases if needed
                iapBloc.add(IAPLoadProductsEvent(IAPHelper.allProductIds));
              }
            }
          }
          if (state is IAPProductsLoadedState) {
            setState(() {
              // Update UI with loaded products
              weekly = state.weekly;
              monthly = state.monthly;
              yearly = state.yearly;
              lifetime = state.lifetime;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_buildProductsList(context, iapBloc)],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, IAPBloc iapBloc) {
    return Column(
      children: [
        // Yearly subscription
        if (yearly != null)
          BtnYearlyWidget(
            onPressed: () {
              iapBloc.add(
                IAPPurchaseProductEvent(
                  product: yearly!,
                  isConsumable: false, // Yearly subscription is non-consumable
                ),
              );
            },
            price: yearly!.price,
          ),
        const SizedBox(height: 16),
        if (lifetime != null)
          BtnLifetimeWidget(
            onPressed: () {
              LoadingDialog.show(context, message: 'Processing purchase...');
              iapBloc.add(
                IAPPurchaseProductEvent(
                  product: lifetime!,
                  isConsumable: true, // Lifetime is non-consumable
                ),
              );
            },
            price: lifetime!.price,
          ),
      ],
    );
  }
}
