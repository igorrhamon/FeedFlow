import 'package:flutter/material.dart';
import '../providers/provider_registry.dart';

const _accent = Color(0xFF7C5CFF);
const _bg = Color(0xFF0F0F0F);
const _surface = Color(0xFF1C1C1E);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);

class LoginScreen extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController apiKeyController;
  final TextEditingController baseUrlController;
  final String selectedProviderId;
  final List<ProviderInfo> availableProviders;
  final bool isApiKeyAuth;
  final bool requiresBaseUrl;
  final bool isOAuth2;
  final TextEditingController? clientIdController;
  final TextEditingController? clientSecretController;
  final VoidCallback? onOAuth2Authorize;
  final ValueChanged<String> onProviderChanged;
  final VoidCallback onLogin;
  final bool loading;
  final String? error;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  const LoginScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.apiKeyController,
    required this.baseUrlController,
    required this.selectedProviderId,
    required this.availableProviders,
    required this.isApiKeyAuth,
    this.requiresBaseUrl = false,
    this.isOAuth2 = false,
    this.clientIdController,
    this.clientSecretController,
    this.onOAuth2Authorize,
    required this.onProviderChanged,
    required this.onLogin,
    this.loading = false,
    this.error,
    this.onForgotPassword,
    this.onSignUp,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailController = widget.emailController;
    final passwordController = widget.passwordController;
    final apiKeyController = widget.apiKeyController;
    final baseUrlController = widget.baseUrlController;
    final clientIdController = widget.clientIdController;
    final clientSecretController = widget.clientSecretController;
    final selectedProviderId = widget.selectedProviderId;
    final availableProviders = widget.availableProviders;
    final isApiKeyAuth = widget.isApiKeyAuth;
    final requiresBaseUrl = widget.requiresBaseUrl;
    final isOAuth2 = widget.isOAuth2;
    final onProviderChanged = widget.onProviderChanged;
    final onLogin = widget.onLogin;
    final onOAuth2Authorize = widget.onOAuth2Authorize;
    final loading = widget.loading;
    final error = widget.error;
    final onForgotPassword = widget.onForgotPassword;
    final onSignUp = widget.onSignUp;
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                ),
              ),
              const Text(
                'Entrar',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecione o provedor e entre com suas credenciais',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 28),
              _label('Provedor'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3A3A3C)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProviderId,
                    isExpanded: true,
                    dropdownColor: _surface,
                    style: const TextStyle(color: _textPrimary, fontSize: 15),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondary),
                    onChanged: loading ? null : (v) { if (v != null) onProviderChanged(v); },
                    items: availableProviders.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isApiKeyAuth) ...[
                if (requiresBaseUrl) ...[
                  _label('URL do Servidor'),
                  const SizedBox(height: 8),
                  _field(
                    controller: baseUrlController,
                    hint: 'https://seu-servidor.com/path',
                    keyboardType: TextInputType.url,
                    enabled: !loading,
                  ),
                  const SizedBox(height: 16),
                ],
                _label('API Key'),
                const SizedBox(height: 8),
                _field(
                  controller: apiKeyController,
                  hint: 'Cole sua API key aqui',
                  enabled: !loading,
                ),
              ] else if (isOAuth2) ...[
                _label('Client ID'),
                const SizedBox(height: 8),
                _field(
                  controller: clientIdController!,
                  hint: 'Seu Client ID do Feedly',
                  enabled: !loading,
                ),
                const SizedBox(height: 16),
                _label('Client Secret'),
                const SizedBox(height: 8),
                _field(
                  controller: clientSecretController!,
                  hint: 'Seu Client Secret (opcional)',
                  enabled: !loading,
                ),
              ] else ...[
                if (requiresBaseUrl) ...[
                  _label('URL do Servidor'),
                  const SizedBox(height: 8),
                  _field(
                    controller: baseUrlController,
                    hint: 'https://seu-servidor.com/api/greader.php',
                    keyboardType: TextInputType.url,
                    enabled: !loading,
                  ),
                  const SizedBox(height: 16),
                ],
                _label('E-mail / Usuário'),
                const SizedBox(height: 8),
                _field(
                  controller: emailController,
                  hint: 'seu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !loading,
                ),
                const SizedBox(height: 16),
                _label('Senha'),
                const SizedBox(height: 8),
                _field(
                  controller: passwordController,
                  hint: '••••••••',
                  obscure: true,
                  enabled: !loading,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onForgotPassword,
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              if (error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFF453A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x33FF453A)),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(color: Color(0xFFFF453A), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isOAuth2 ? (loading ? null : onOAuth2Authorize) : (loading ? null : onLogin),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF5C3A20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isOAuth2 ? 'Autorizar com Feedly' : 'Entrar',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: onSignUp,
                  child: const Text.rich(
                    TextSpan(
                      text: 'Não tem conta? ',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Cadastrar',
                          style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary, fontSize: 15),
      cursorColor: _accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
      ),
    );
  }
}
