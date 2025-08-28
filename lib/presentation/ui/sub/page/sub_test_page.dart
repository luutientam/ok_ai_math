import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package/app_package.dart';

class SubTestPage extends StatefulWidget {
  const SubTestPage({super.key});

  @override
  State<SubTestPage> createState() => _SubTestPageState();
}

class _SubTestPageState extends State<SubTestPage> {
  SubConfig? _subConfig;
  SubscriptionStatus? _subscriptionStatus;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfigSubBloc, ConfigSubState>(
      listener: (context, state) {
        // Lắng nghe state changes từ BLoC và update local state
        if (state is ConfigSubLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is ConfigSubLoaded) {
          setState(() {
            _subConfig = state.subConfig;
            _subscriptionStatus = state.subscriptionStatus;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is SubscriptionStatusLoaded) {
          print(
            'Subscription status loaded: ${state.subscriptionStatus.activeProductId}, ${state.subscriptionStatus.isActive}, ${state.subscriptionStatus.hasLifetime}, ${state.subscriptionStatus.expiryDate}, ${state.subscriptionStatus.message}, ${state.subscriptionStatus.isActive}',
          );
          setState(() {
            _subscriptionStatus = state.subscriptionStatus;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is ConfigSubErrorState) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      },
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    // if (_isLoading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sub Test Page')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<ConfigSubBloc>().add(const ConfigSubStarted());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_subConfig == null) {
      return const Scaffold(body: Center(child: Text('No data available')));
    }

    return _buildContent(context, _subConfig!);
  }

  Widget _buildContent(BuildContext context, SubConfig subConfig) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sub Test Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Config Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Config Data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'isSub: ${subConfig.isSub}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'isLifetime: ${subConfig.isLifetime}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'isRemoveAd: ${subConfig.isRemoveAd}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Config Update Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Config',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ConfigSubBloc>().add(
                          ConfigSubUpdateEvent(
                            subConfig.copyWith(isSub: !subConfig.isSub),
                          ),
                        );
                      },
                      child: const Text(
                        'Toggle Sub Status',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ConfigSubBloc>().add(
                          ConfigSubUpdateEvent(
                            subConfig.copyWith(
                              isLifetime: !subConfig.isLifetime,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Toggle Lifetime',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ConfigSubBloc>().add(
                          ConfigSubUpdateEvent(
                            subConfig.copyWith(
                              isRemoveAd: !subConfig.isRemoveAd,
                            ),
                          ),
                        );
                      },
                      child: const Text('Toggle Remove Ad'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subscription Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iOS Subscription Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_subscriptionStatus != null) ...[
                      _buildStatusRow(
                        'Active:',
                        _subscriptionStatus!.isActive ? 'Yes' : 'No',
                      ),
                      _buildStatusRow(
                        'Product ID:',
                        _subscriptionStatus!.activeProductId ?? 'N/A',
                      ),
                      _buildStatusRow(
                        'Has Lifetime:',
                        _subscriptionStatus!.hasLifetime ? 'Yes' : 'No',
                      ),
                      _buildStatusRow(
                        'Expiry Date:',
                        _subscriptionStatus!.expiryDate?.toString() ?? 'N/A',
                      ),
                      _buildStatusRow('Message:', _subscriptionStatus!.message),
                      const SizedBox(height: 10),
                    ] else ...[
                      const Text(
                        'No subscription data fetched yet',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        context.read<ConfigSubBloc>().add(
                          const FetchSubscriptionStatusEvent(),
                        );
                      },
                      child: const Text('Fetch iOS Subscription Status'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
