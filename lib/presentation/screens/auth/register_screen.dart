import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Akun Social Hub',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Daftarkan diri Anda untuk mulai berbagi video dan berinteraksi.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                if (authProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Contoh: Ahmad Fauzi',
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary, size: 20),
                  validator: (val) => val == null || val.isEmpty ? 'Nama lengkap wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                  hintText: 'Contoh: ahmad_fauzi',
                  prefixIcon: const Icon(Icons.alternate_email, color: AppColors.textSecondary, size: 20),
                  validator: (val) => val == null || val.isEmpty ? 'Username wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  labelText: 'Alamat Email',
                  hintText: 'Contoh: ahmad@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textSecondary, size: 20),
                  validator: (val) => val == null || !val.contains('@') ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Kata Sandi',
                  hintText: 'Minimal 6 karakter',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Kata Sandi',
                  hintText: 'Ulangi kata sandi',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_reset, color: AppColors.textSecondary, size: 20),
                  validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Daftar Sekarang',
                  isLoading: isLoading,
                  backgroundColor: AppColors.primary,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
