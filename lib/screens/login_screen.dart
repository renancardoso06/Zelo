import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/app_provider.dart';
import '../services/api_client.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isRegister = false;
  TipoUsuario _tipo = TipoUsuario.CLIENTE;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _telefoneCtrl.dispose();
    _enderecoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final appProvider = context.read<AppProvider>();
    try {
      if (_isRegister) {
        await appProvider.registrar(
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          senha: _passwordCtrl.text,
          tipo: _tipo,
          telefone: _telefoneCtrl.text.trim(),
          endereco: _enderecoCtrl.text.trim(),
        );
      } else {
        await appProvider.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final msg = (e.fieldErrors != null && e.fieldErrors!.isNotEmpty)
          ? e.fieldErrors!.values.join('\n')
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: ZeloColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado. Tente novamente.'),
          backgroundColor: ZeloColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: ZeloColors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Zelo',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: ZeloColors.primary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Cuidado que você merece',
                        style: TextStyle(
                          fontSize: 15,
                          color: ZeloColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  _isRegister ? 'Criar conta' : 'Bem-vindo de volta',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ZeloColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegister
                      ? 'Preencha seus dados para começar'
                      : 'Faça login para continuar',
                  style: const TextStyle(
                    color: ZeloColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isRegister) ...[
                  // Tipo de conta
                  SegmentedButton<TipoUsuario>(
                    segments: const [
                      ButtonSegment(
                        value: TipoUsuario.CLIENTE,
                        label: Text('Cliente'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: TipoUsuario.PRESTADOR,
                        label: Text('Prestador'),
                        icon: Icon(Icons.handyman_outlined),
                      ),
                    ],
                    selected: {_tipo},
                    onSelectionChanged: (s) => setState(() => _tipo = s.first),
                  ),
                  const SizedBox(height: 16),
                  // Nome
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) {
                      if (!_isRegister) return null;
                      if (v == null || v.trim().isEmpty) return 'Informe o nome';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Senha
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 16),
                  // Telefone (opcional)
                  TextFormField(
                    controller: _telefoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone (opcional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Endereço (opcional)
                  TextFormField(
                    controller: _enderecoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Endereço (opcional)',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Botão principal
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isRegister ? 'Criar conta' : 'Entrar'),
                ),
                const SizedBox(height: 16),
                // Toggle login/cadastro
                Center(
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister
                          ? 'Já tenho conta — fazer login'
                          : 'Não tenho conta — criar agora',
                      style: const TextStyle(color: ZeloColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
