// ----- Màn hình Giao diện Người dùng (UI) -----
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/routes/app_routes.dart';
import '../bloc/setting_bloc.dart';
import '../bloc/setting_event.dart';
import '../bloc/setting_state.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc()..add(FetchSettings()),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          title: const Text(
            'Setting',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF181D27),
          elevation: 0,
        ),
        body: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            if (state is SettingLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingLoadedState) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildPremiumBanner(context, state.isPremium),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.favorites);

                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDB1616), // nền vàng
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ic_favorites.svg',
                            width: 28,
                            height: 28,
                            color: const Color(0xFF000000), // icon đỏ
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Favorites',
                            style: TextStyle(
                              color: Color(0xFF000000), // chữ đỏ
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    context,
                    iconPath: 'assets/icons/ic_policy.svg',
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    context,
                    iconPath: 'assets/icons/ic_terms.svg',
                    title: 'Term of Use',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    context,
                    iconPath: 'assets/icons/ic_share.svg',
                    title: 'Share App',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    context,
                    iconPath: 'assets/icons/ic_rate.svg',
                    title: 'Rating App',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    context,
                    iconPath: 'assets/icons/ic_app_version.svg',
                    title: 'App Version',
                    trailingText: '1.0.0',
                    onTap: () {},
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Something went wrong!', style: TextStyle(color: Colors.white)));
            }
          },
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context, bool isPremium) {
    return InkWell(
      onTap: () {
        if (!isPremium) {
          BlocProvider.of<SettingBloc>(context).add(UpgradePremiumPressed());
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/img_setting_up_pre.webp',
          width: double.infinity,
          height: 150,
        ),
      ),
    );
  }
  Widget _buildOptionTile(
      BuildContext context, {
        required String iconPath,
        required String title,
        Color color = Colors.grey,
        String? trailingText,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D12),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          iconPath,
          width: 28,
          height: 28,
        ),

        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: trailingText != null
            ? Text(
          trailingText,
          style: const TextStyle(color: Colors.white70),
        )
            : null,
        onTap: onTap,
      ),
    );
  }
}
