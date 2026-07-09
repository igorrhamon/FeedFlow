import 'package:flutter/material.dart';

import '../providers/feed_provider.dart';
import '../providers/provider_registry.dart';
import '../providers/auth/auth_config.dart';
import '../services/provider_settings.dart';
import '../providers/feedly/feedly_auth.dart';
import 'login_screen.dart';

class LoginPage extends StatefulWidget {
  final void Function(FeedProvider provider)? onLogin;
  const LoginPage({super.key, this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  String? _error;
  bool _loading = false;
  String _selectedProviderId = 'theoldreader';

  List<ProviderInfo> get _availableProviders => ProviderRegistry.getAvailableProviders();

  ProviderInfo? get _selectedProviderInfo =>
      _availableProviders.where((p) => p.id == _selectedProviderId).firstOrNull;

  bool get _isApiKeyAuth =>
      _selectedProviderInfo?.authTypes.contains(AuthType.apiKey) ?? false;

  bool get _isBasicAuth =>
      _selectedProviderInfo?.authTypes.contains(AuthType.basicAuth) ?? false;

  bool get _isOAuth2 =>
      _selectedProviderInfo?.authTypes.contains(AuthType.oauth2) ?? false;

  bool get _requiresBaseUrl =>
      _selectedProviderInfo?.requiresBaseUrl ?? false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  void _authorizeOAuth2() async {
    final clientId = _clientIdController.text.trim();
    if (clientId.isEmpty) {
      setState(() => _error = 'Informe o Client ID.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final clientSecret = _clientSecretController.text.trim();
      final provider = ProviderRegistry.create(_selectedProviderId);
      if (provider == null) throw Exception('Provider não disponível');
      final config = await FeedlyAuth.authorize(clientId, clientSecret: clientSecret);
      final result = await provider.authenticate(config);
      if (result.success) {
        await ProviderSettings.setActiveProvider(_selectedProviderId);
        await ProviderSettings.saveAuthConfig(_selectedProviderId, config);
        if (widget.onLogin != null) widget.onLogin!(provider);
        return;
      }
      setState(() {
        _error = result.error ?? 'Falha na autorização.';
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Erro: $e'; _loading = false; });
    }
  }

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = ProviderRegistry.create(_selectedProviderId);
      if (provider == null) {
        setState(() {
          _error = 'Provider não disponível.';
          _loading = false;
        });
        return;
      }

      Object config;
      if (_isApiKeyAuth) {
        final apiKey = _apiKeyController.text.trim();
        if (apiKey.isEmpty) {
          setState(() {
            _error = 'Informe a API key.';
            _loading = false;
          });
          return;
        }
        final baseUrl = _baseUrlController.text.trim();
        config = ApiKeyAuthConfig(
          providerId: _selectedProviderId,
          apiKey: apiKey,
          baseUrl: baseUrl.isNotEmpty ? baseUrl : null,
        );
      } else if (_isBasicAuth) {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        if (email.isEmpty || password.isEmpty) {
          setState(() {
            _error = 'Informe o e-mail/usuário e a senha.';
            _loading = false;
          });
          return;
        }
        final baseUrl = _baseUrlController.text.trim();
        config = BasicAuthConfig(
          providerId: _selectedProviderId,
          username: email,
          password: password,
          baseUrl: baseUrl.isNotEmpty ? baseUrl : null,
        );
      } else {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        if (email.isEmpty || password.isEmpty) {
          setState(() {
            _error = 'Informe o e-mail e a senha.';
            _loading = false;
          });
          return;
        }
        config = GoogleLoginAuthConfig(
          providerId: _selectedProviderId,
          email: email,
          password: password,
          authToken: '',
        );
      }

      final result = await provider.authenticate(config);
      if (result.success) {
        await ProviderSettings.setActiveProvider(_selectedProviderId);
        if (config is GoogleLoginAuthConfig) {
          await ProviderSettings.saveAuthConfig(_selectedProviderId, config);
        } else if (config is ApiKeyAuthConfig) {
          await ProviderSettings.saveAuthConfig(_selectedProviderId, config);
        } else if (config is BasicAuthConfig) {
          await ProviderSettings.saveAuthConfig(_selectedProviderId, config);
        }
        if (widget.onLogin != null) widget.onLogin!(provider);
        return;
      }

      setState(() {
        _error = result.error ?? 'Credenciais inválidas.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro: $e';
        _loading = false;
      });
    }
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acesse o site do seu provedor para recuperar a senha')),
    );
  }

  void _onSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acesse o site do seu provedor para criar uma conta')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      emailController: _emailController,
      passwordController: _passwordController,
      apiKeyController: _apiKeyController,
      baseUrlController: _baseUrlController,
      selectedProviderId: _selectedProviderId,
      availableProviders: _availableProviders,
      isApiKeyAuth: _isApiKeyAuth,
      requiresBaseUrl: _requiresBaseUrl,
      isOAuth2: _isOAuth2,
      clientIdController: _clientIdController,
      clientSecretController: _clientSecretController,
      onOAuth2Authorize: _isOAuth2 && !_loading ? _authorizeOAuth2 : null,
      onProviderChanged: (id) => setState(() {
        _selectedProviderId = id;
        _error = null;
      }),
      onLogin: _loading ? () {} : _login,
      loading: _loading,
      error: _error,
      onForgotPassword: _onForgotPassword,
      onSignUp: _onSignUp,
    );
  }
}
