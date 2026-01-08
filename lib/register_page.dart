import 'package:flutter/material.dart';

enum RegisterType { user, operator }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterType selectedType = RegisterType.user;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔹 TOP ROLE SELECTOR
          _buildRoleSelector(),

          const SizedBox(height: 20),

          // 🔹 FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: selectedType == RegisterType.user
                    ? _userForm()
                    : _operatorForm(),
              ),
            ),
          ),
        ],
      ),

      // 🔹 BOTTOM BUTTON
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // ======================================================
  // ROLE SELECTOR
  // ======================================================

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roleButton("User", RegisterType.user),
        const SizedBox(width: 10),
        _roleButton("Operator", RegisterType.operator),
      ],
    );
  }

  Widget _roleButton(String title, RegisterType type) {
    final bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ======================================================
  // USER FORM
  // ======================================================

  Widget _userForm() {
    return Column(
      children: [
        _inputField("Full Name"),
        const SizedBox(height: 12),

        _inputField("Email"),
        const SizedBox(height: 12),

        _inputField("Phone Number"),
        const SizedBox(height: 12),

        _inputField("Password", isPassword: true),
      ],
    );
  }

  // ======================================================
  // OPERATOR FORM
  // ======================================================

  Widget _operatorForm() {
    return Column(
      children: [
        _inputField("Operator Name"),
        const SizedBox(height: 12),

        _inputField("Company Name"),
        const SizedBox(height: 12),

        _inputField("Vehicle Number"),
        const SizedBox(height: 12),

        _inputField("Phone Number"),
        const SizedBox(height: 12),

        _inputField("Password", isPassword: true),
      ],
    );
  }

  // ======================================================
  // COMMON INPUT FIELD
  // ======================================================

  Widget _inputField(String label, {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  // ======================================================
  // BOTTOM BUTTON
  // ======================================================

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (selectedType == RegisterType.user) {
              debugPrint("User Registered");
            } else {
              debugPrint("Operator Registered");
            }
          }
        },
        child: Text(
          selectedType == RegisterType.user
              ? "Register as User"
              : "Register as Operator",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
