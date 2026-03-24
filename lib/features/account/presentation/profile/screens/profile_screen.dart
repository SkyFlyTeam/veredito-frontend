import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/profile/providers/profile_provider.dart';
import 'package:flutter_cookiecutter/routes/app_router.dart';
import 'package:toastification/toastification.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_checkChanges);
    emailController.addListener(_checkChanges);
    passwordController.addListener(_checkChanges);

    // Load profile on start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(sessionProvider);
      if (currentUser != null) {
        ref.read(profileViewModelProvider.notifier).loadProfile(currentUser.id);
      }
    });
  }

  void _checkChanges() {
    final state = ref.read(profileViewModelProvider);
    final user = state.user;
    if (user != null) {
      final changed = nameController.text != user.fullName ||
          emailController.text != user.email ||
          passwordController.text.isNotEmpty;
      if (changed != _hasChanges) {
        setState(() {
          _hasChanges = changed;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_checkChanges);
    emailController.removeListener(_checkChanges);
    passwordController.removeListener(_checkChanges);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    final user = ref.read(profileViewModelProvider).user;
    if (user != null) {
      ref.read(profileViewModelProvider.notifier).updateProfile(
            user.id,
            nameController.text,
            emailController.text,
            passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);

    // Listen to success/error to show snackbars
    ref.listen(profileViewModelProvider, (previous, next) {
      if (next.successMessage != null && previous?.successMessage == null) {
        // Reset password field and triggers UI re-evaluation
        passwordController.clear();
        _checkChanges();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    // Update controllers when user is loaded
    if (state.user != null) {
      if (nameController.text.isEmpty && state.user!.fullName.isNotEmpty) {
        nameController.text = state.user!.fullName;
      }
      if (emailController.text.isEmpty && state.user!.email.isNotEmpty) {
        emailController.text = state.user!.email;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Perfil',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 40),
          Text(
            'Editar informações',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 30),
          if (state.error != null) _buildErrorBanner(state.error!),
          _buildFieldLabel('Nome completo'),
          _buildTextField(
            controller: nameController,
            icon: Icons.person_outline,
            hint: 'Digite seu nome',
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Email'),
          _buildTextField(
            controller: emailController,
            icon: Icons.alternate_email,
            hint: 'email@gmail.com',
            hasError: state.error != null && state.error!.contains('email'),
          ),
          if (state.error != null && state.error!.contains('email'))
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                'Email já existente',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.red500),
              ),
            ),
          const SizedBox(height: 20),
          _buildFieldLabel('Senha'),
          _buildTextField(
            controller: passwordController,
            icon: Icons.lock_outline,
            hint: '************************',
            isPassword: true,
          ),
          const SizedBox(height: 20),
          if (_hasChanges)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                  onPressed: state.isSaving ? null : _onSave,
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(state.isSaving ? 'Salvando...' : 'Salvar'),
                ),
              ),
            ),
          const SizedBox(height: 40),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(profileViewModelProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.login,
                    (route) => false,
                  );
                }
              },
              icon: Icon(Icons.logout, color: AppColors.red500),
              label: const Text(
                'Sair',
                style: TextStyle(color: AppColors.red500, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool hasError = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: hasError ? Icon(Icons.error_outline, color: AppColors.red500) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.red500 : AppColors.gray700,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.red500 : AppColors.gray100,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.red500.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
