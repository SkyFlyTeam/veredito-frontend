import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../login/providers/session_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/widgets/message_box.dart';
import 'package:toastification/toastification.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _hasChanges = false;
  bool _obscurePassword = true;
  String? _localError;
  String? _emailError;
  String? _passwordError;

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
    setState(() {
      _localError = null;
      _emailError = null;
      _passwordError = null;
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty) {
      setState(() {
        _localError = 'Nome completo não preenchido.';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _localError = 'Email não preenchido.';
        _emailError = 'Campo obrigatório';
      });
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _localError = 'Email inválido. Informe um email válido com @.';
        _emailError = 'Email inválido';
      });
      return;
    }

    if (password.isNotEmpty && !_passwordRegex.hasMatch(password)) {
      setState(() {
        _localError =
            'Senha inválida. Use ao menos 8 caracteres, com letra maiúscula, número e caractere especial.';
        _passwordError = 'Senha Fraca';
      });
      return;
    }

    final user = ref.read(profileViewModelProvider).user;
    if (user != null) {
      ref.read(profileViewModelProvider.notifier).updateProfile(
            user.id,
            name,
            email,
            password,
          );
    }
  }

  void resetFields() {
    final state = ref.read(profileViewModelProvider);
    final user = state.user;
    if (user != null) {
      setState(() {
        nameController.text = user.fullName;
        emailController.text = user.email;
        passwordController.clear();
        _hasChanges = false;
        _localError = null;
        _emailError = null;
        _passwordError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);

    // Update controllers when user is loaded (initial load)
    if (state.user != null) {
      if (nameController.text.isEmpty && state.user!.fullName.isNotEmpty && !_hasChanges) {
        nameController.text = state.user!.fullName;
      }
      if (emailController.text.isEmpty && state.user!.email.isNotEmpty && !_hasChanges) {
        emailController.text = state.user!.email;
      }
    }

    // Listen to success/error to show snackbars
    ref.listen(profileViewModelProvider, (previous, next) {
      if (next.resetCount > (previous?.resetCount ?? 0)) {
        resetFields();
      }

      if (next.successMessage != null && previous?.successMessage == null) {
        // Reset password field and triggers UI re-evaluation
        passwordController.clear();
        _checkChanges();

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text("Sucesso"),
          description: Text(next.successMessage!),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }
    });

    // Update controllers when user is loaded (initial load)
    if (state.user != null) {
      if (nameController.text.isEmpty && state.user!.fullName.isNotEmpty && !_hasChanges) {
        nameController.text = state.user!.fullName;
      }
      if (emailController.text.isEmpty && state.user!.email.isNotEmpty && !_hasChanges) {
        emailController.text = state.user!.email;
      }
    }

    final displayError = _localError ?? state.error;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          if (displayError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: MessageBox(
                message: displayError,
                variant: MessageBoxVariant.error,
              ),
            ),
          _buildFieldLabel('Nome completo'),
          _buildTextField(
            controller: nameController,
            icon: Icons.person_outline,
            hint: 'Digite seu nome',
            hasError: _localError?.toLowerCase().contains('nome') ?? false,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Email'),
          _buildTextField(
            controller: emailController,
            icon: Icons.alternate_email,
            hint: 'email@gmail.com',
            hasError: _emailError != null || (state.error != null && state.error!.toLowerCase().contains('email')),
          ),
          if (_emailError != null) 
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                _emailError!,
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
            hasError: _passwordError != null,
          ),
          if (_passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                _passwordError!,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.red500),
              ),
            ),
          const SizedBox(height: 20),
          if (_hasChanges)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 190,
                child: ElevatedButton.icon(
                  onPressed: state.isSaving ? () {} : _onSave,
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
                  label: Text(
                    state.isSaving ? 'Salvando...' : 'Salvar',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
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
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.red500),
    );

    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: hasError ? AppColors.red500 : Colors.white70,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPassword)
              IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: hasError ? AppColors.red500 : Colors.white70,
                ),
              ),
            if (hasError)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.error_outline_rounded, color: AppColors.red500),
              ),
          ],
        ),
        enabledBorder: hasError ? errorBorder : null,
        focusedBorder: hasError ? errorBorder : null,
      ),
    );
  }
}
