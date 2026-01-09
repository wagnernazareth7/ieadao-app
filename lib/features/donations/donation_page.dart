import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'donation_controller.dart';

class DonationPage extends ConsumerStatefulWidget {
  const DonationPage({super.key});

  @override
  ConsumerState<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends ConsumerState<DonationPage> {
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minhas Ofertas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.primary,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oferta Voluntária', 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('\"Cada um dê conforme determinou em seu coração.\"', 
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escolha a categoria:', style: AppTextStyles.heading),
                  const SizedBox(height: 16),
                  
                  _DonationOption(
                    title: 'Dízimo Mensal',
                    icon: Icons.calendar_month,
                    color: Colors.blue,
                    onTap: () => _showDonationDialog(context, 'Dízimo Mensal'),
                  ),
                  _DonationOption(
                    title: 'Construção',
                    icon: Icons.foundation,
                    color: Colors.orange,
                    onTap: () => _showDonationDialog(context, 'Construção'),
                  ),
                  _DonationOption(
                    title: 'Dízimo Semanal',
                    icon: Icons.update,
                    color: Colors.green,
                    onTap: () => _showDonationDialog(context, 'Dízimo Semanal'),
                  ),
                  _DonationOption(
                    title: 'Outro',
                    icon: Icons.add_circle_outline,
                    color: Colors.purple,
                    onTap: () => _showDonationDialog(context, 'Outro'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationDialog(BuildContext context, String type) {
    _amountCtrl.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Lançar $type', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Insira o valor da sua contribuição:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: 'MZN',
                border: OutlineInputBorder(),
                hintText: '0.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountCtrl.text) ?? 0;
              if (amount <= 0) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              await ref.read(donationControllerProvider).addDonation(
                memberId: user.uid,
                memberName: user.email?.split('@')[0] ?? 'Membro',
                amount: amount,
                type: type,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oferta registrada com sucesso! Amém.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('REGISTRAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DonationOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DonationOption({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.add, size: 18),
        onTap: onTap,
      ),
    );
  }
}
