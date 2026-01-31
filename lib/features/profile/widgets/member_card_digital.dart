import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/models/app_user.dart';
import '../../../core/theme/app_colors.dart';

class MemberCardDigital extends StatelessWidget {
  final AppUser user;
  final VoidCallback onPhotoTap;

  const MemberCardDigital({
    super.key,
    required this.user,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.church, size: 150, color: Colors.white.withValues(alpha: 0.05)),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: onPhotoTap,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: (user.photoUrl != null && user.photoUrl!.contains(','))
                              ? DecorationImage(
                                  image: MemoryImage(base64Decode(user.photoUrl!.split(',').last)), 
                                  fit: BoxFit.cover
                                )
                              : const DecorationImage(
                                  image: AssetImage('assets/images/placeholder_user.png'), 
                                  fit: BoxFit.cover
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.verified, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MEMBRO OFICIAL',
                        style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.firstName} ${user.lastName}'.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _buildMiniInfo(Icons.shield_outlined, 'CARGO', user.roles.first.toUpperCase()),
                      const SizedBox(height: 4),
                      _buildMiniInfo(Icons.calendar_today_outlined, 'DESDE', '2024'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'IEADAO TSALALA',
                  style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                // CORREÇÃO SÉNIOR: Usando ícone nativo em vez de SVG externo problemático
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 10),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
