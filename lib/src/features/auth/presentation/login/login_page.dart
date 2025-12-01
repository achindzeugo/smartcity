// lib/src/features/auth/presentation/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _remember = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validatePhone(String? v) {
    // Accept any non-empty for now; in prod add a stricter phone regex
    if (v == null || v.isEmpty) return null; // allow empty in dev mode
    if (v.length < 3) return 'Numéro invalide';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    // Simuler délai réseau
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _loading = false);

    // Mode dev : si les champs sont vides -> authoriser la connexion
    if (phone.isEmpty && password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Connexion (mode dev)')));
        context.go('/home'); // adapte la route home
        return;
      }
    }

    // Creds de test : client / client (phone = client, password = client)
    if (phone == 'client' && password == 'client') {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Connexion réussie')));
        context.go('/home');
        return;
      }
    }

    // Ici, tu peux appeler ton API réel (Dio) pour authentifier via téléphone.
    // Exemple de fallback : accepter n'importe quel contenu numérique comme "tel"
    // mais pour l'instant on indique une erreur si aucun des cas précédents n'est vrai.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro ou mot de passe incorrect')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.green.shade700;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // si la pile native peut pop, on pop, sinon on navigue vers /home (ou '/')
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home'); // ou context.go('/') selon ton flow attendu
            }
          },
        ),

      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Bienvenue',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Connectez-vous avec votre numéro de téléphone.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // PHONE
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: const Icon(Icons.phone_android_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'ex: +2376xxxxxxx ou client',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'client',
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v ?? false),
                              activeColor: primary,
                            ),
                            const SizedBox(width: 4),
                            const Text('Se souvenir'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset non implémenté')),
                            );
                          },
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Se connecter', style: TextStyle(fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hint dev
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow.shade200),
                      ),
                      child: const Text(
                        'Mode dev: laissez les champs vides pour vous connecter automatiquement, ou utilisez client/client.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
