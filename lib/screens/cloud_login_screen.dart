import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudLoginScreen extends StatefulWidget {
  const CloudLoginScreen({super.key});

  @override
  State<CloudLoginScreen> createState() => _CloudLoginScreenState();
}

class _CloudLoginScreenState extends State<CloudLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Temporary function for testing: allows users to sign up and assign a role
  Future<void> _signUpAs(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Store the role in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'role': role,
        'email': _emailController.text.trim(),
      });
      
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Privacy QR Platform',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Log in with your institution account', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
                
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      child: const Text('Secure Login'),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('Demo Environment: Create New Account', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _signUpAs('student'),
                            child: const Text('As Student'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _signUpAs('security'),
                            child: const Text('As Security'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
