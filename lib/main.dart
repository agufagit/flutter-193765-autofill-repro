import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AutofillProbe()));

class AutofillProbe extends StatefulWidget {
  const AutofillProbe({super.key});

  @override
  State<AutofillProbe> createState() => _AutofillProbeState();
}

class _AutofillProbeState extends State<AutofillProbe> {
  final username = TextEditingController(text: '+12025550148');
  final password = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AutofillGroup(
          onDisposeAction: AutofillContextAction.cancel,
          child: Column(
            children: [
              const Text('Local autofill diagnostic; no account or server'),
              TextField(controller: username, readOnly: true, autofillHints: const [AutofillHints.username]),
              TextField(
                controller: password,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
