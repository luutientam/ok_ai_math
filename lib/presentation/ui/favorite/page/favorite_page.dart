  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_svg/svg.dart';
  import '../../../../core/di/di.dart';
  import '../../solve/bloc/solve_state.dart';
  import '../../solve/page/solve_page.dart';
  import '../../solve/page/solve_success.dart';
  import '../bloc/favorite_bloc.dart';
  import '../bloc/favorite_event.dart';
  import '../bloc/favorite_state.dart';
  import '../../../../domain/models/math.dart';
  import '../../solve/bloc/solve_bloc.dart';

  class FavoritesPage extends StatelessWidget {
    const FavoritesPage({super.key});

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => sl<FavoritesPhotoBloc>()..add(LoadFavoritesPhoto()),
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0D12),
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 80, // chiều cao AppBar
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/ic_back_formula.svg',
                width: 56,
                height: 56,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Favorites',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: BlocBuilder<FavoritesPhotoBloc, FavoritesPhotoState>(
            builder: (context, state) {
              if (state is FavoritesPhotoLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FavoritesPhotoLoaded) {
                final favorites = state.favorites;
                print('Favorites: $favorites');
                print('Favorites length: ${favorites.length}');
                if (favorites.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final math = favorites[index];
                    final bytes = File(math.imageUri).readAsBytes();
                    return GestureDetector(
                      onTap: () async {
                        try {
                          final bytes = await File(math.imageUri).readAsBytes();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SolvePage(
                                imageBytes: bytes,
                                initialId: math.uid,
                                isFromFavorite: math.isFavorite,
                              ),
                            ),
                          ).then((_) {
                            // Khi SolvePage đóng -> reload favorites
                            context.read<FavoritesPhotoBloc>().add(LoadFavoritesPhoto());
                          });

                          print('Math uid: ${math.uid}');
                          print('Math imageUri: ${math.imageUri}');
                          print('Math solution: ${math.solution}');
                          print('Math result: ${math.result}');
                          print('Math isFavorite: ${math.isFavorite}');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error loading image')),
                          );
                        }
                      },

                      child: Container(
                        height: 130, // tổng chiều cao item
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0D12),
                          borderRadius: BorderRadius.circular(0),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Stack(
                          children: [
                            // Phần trên có thể chứa text, info, ... (chiều cao còn lại)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'Photo',
                                style: TextStyle(
                                  color: const Color(0xFFDB1616), // màu vàng #EDEF5D// nếu muốn in đậm
                                ),
                              ),
                            ),
                            // Chữ nhật con chứa ảnh, cao 70, căn xuống dưới cách đáy 16
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 16,
                              height: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: math.imageUri != null && math.imageUri!.isNotEmpty
                                    ? Image.file(
                                  File(math.imageUri!),
                                  width: double.infinity,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                                    : Container(
                                  color: Colors.black12,
                                  child: const Center(
                                    child: Text(
                                      'No Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),



                    );
                  },
                );
              } else if (state is FavoritesPhotoError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      );
    }
  }
