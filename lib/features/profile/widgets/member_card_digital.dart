import 'dart:convert'; // Para Base64
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/app_user.dart';

class MemberCardDigital extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onPhotoTap;

  const MemberCardDigital({super.key, required this.user, this.onPhotoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CARTÃO DE MEMBRO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  Text('IEADAO MOÇAMBIQUE • TSALALA', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              if (user.isBaptized)
                _buildBaptismTag(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              _buildQrCode(),
              const SizedBox(width: 16),
              _buildMemberInfo(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? image;
    
    // CORREÇÃO SÉNIOR: Detecção de Foto Base64 ou URL
    if (user.photoUrl != null && user.photoUrl!.startsWith('data:image')) {
      try {
        final base64Str = user.photoUrl!.split(',').last;
        image = MemoryImage(base64Decode(base64Str));
      } catch (e) {
        debugPrint('Erro no decode Base64: $e');
      }
    } else if (user.photoUrl != null && user.photoUrl!.startsWith('http')) {
      image = CachedNetworkImageProvider(user.photoUrl!);
    } else if (user.address != null && user.address!.startsWith('http')) {
      image = CachedNetworkImageProvider(user.address!);
    }

    return GestureDetector(
      onTap: onPhotoTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            backgroundImage: image,
            child: image == null 
                ? const Icon(Icons.person, color: Colors.white, size: 40) 
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: QrImageView(data: user.uid, version: QrVersions.auto, size: 60.0),
    );
  }

  Widget _buildMemberInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email.split('@')[0].toUpperCase(), 
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
          Text('CARGO: ${user.roles.join(", ").toUpperCase()}', 
            style: const TextStyle(color: Colors.white70, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          const Text('MEMBRO ATIVO', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBaptismTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent, width: 0.5)),
      child: const Row(
        children: [
          Icon(Icons.water_drop, color: Colors.cyanAccent, size: 10),
          SizedBox(width: 4),
          Text('BATIZADO', style: TextStyle(color: Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
