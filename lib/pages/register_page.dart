import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Import the new calculator!
import '../utils/nutrition_calculator.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // --- Account Controllers ---
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Profile Controllers ---
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // --- Profile Dropdowns ---
  String _selectedSex = 'Male';
  String _selectedActivityLevel = 'moderate';
  String _selectedGoalType = 'maintain';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Parse the user inputs safely
        int age = int.parse(_ageController.text.trim());
        double height = double.parse(_heightController.text.trim());
        double weight = double.parse(_weightController.text.trim());

        // 2. AUTOMATICALLY calculate the nutrition goals!
        Map<String, int> calculatedGoals = NutritionCalculator.calculateGoals(
          weight: weight,
          height: height,
          age: age,
          sex: _selectedSex,
          activityLevel: _selectedActivityLevel,
          goalType: _selectedGoalType,
        );

        // 3. Send everything to Firebase via AuthService
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(),
          age: age,
          sex: _selectedSex,
          height: height,
          weight: weight,
          activityLevel: _selectedActivityLevel,
          goalType: _selectedGoalType,
          dailyCalories: calculatedGoals['dailyCalories']!,
          protein: calculatedGoals['protein']!,
          carbs: calculatedGoals['carbs']!,
          fats: calculatedGoals['fats']!,
        );

        // 4. Firebase auto-logs in the user. We sign them out so they stay on the Login side of AuthGate.
        await _authService.signOut();

        if (mounted) {
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created successfully! Please log in."),
              backgroundColor: Colors.green,
            ),
          );
          
          // 5. Pop the Register screen to return to the Login screen
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Helpers for numeric validation
  String? _validateInt(String? val, String fieldName) {
    if (val == null || val.isEmpty) return "Enter $fieldName";
    if (int.tryParse(val) == null) return "Must be a valid integer";
    return null;
  }

  String? _validateDouble(String? val, String fieldName) {
    if (val == null || val.isEmpty) return "Enter $fieldName";
    if (double.tryParse(val) == null) return "Must be a valid number";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Account details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Enter a username" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.contains('@') ? null : "Enter a valid email",
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val!.length < 6 ? "Password must be 6+ chars" : null,
              ),
              const Divider(height: 40),

              const Text("Profile Data (Calculates your Macros!)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (val) => _validateInt(val, "age"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSex,
                      decoration: const InputDecoration(labelText: "Sex", border: OutlineInputBorder()),
                      items: ['Male', 'Female'].map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSex = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => _validateDouble(val, "height"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => _validateDouble(val, "weight"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: const InputDecoration(labelText: "Activity Level", border: OutlineInputBorder()),
                items: ['low', 'moderate', 'high'].map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _selectedActivityLevel = val!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGoalType,
                decoration: const InputDecoration(labelText: "Goal Type", border: OutlineInputBorder()),
                items: ['lose', 'maintain', 'gain'].map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _selectedGoalType = val!),
              ),
              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text("Register & Calculate Macros", style: TextStyle(fontSize: 18)),
                      ),
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}