import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../models/user_model.dart';
import '../service/api_caller.dart';
import '../theme/theme_data.dart';
import '../utils/urls.dart';
import '../widgets/screen_background.dart';
import 'login_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});
  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = AuthController.userData;
    emailController.text = user?.email ?? '';
    firstNameController.text = user?.firstName ?? '';
    lastNameController.text = user?.lastName ?? '';
    mobileController.text = user?.mobile ?? '';
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => isSubmitting = true);

    final requestBody = <String, dynamic>{
      'email': emailController.text.trim(),
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'mobile': mobileController.text.trim(),
    };
    if (passwordController.text.trim().isNotEmpty) {
      requestBody['password'] = passwordController.text.trim();
    }

    final response = await ApiCaller.postRequest(
      url: Urls.profileUpdateURL,
      body: requestBody,
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (response.isSuccess) {
      final model = UserModel(
        sId: AuthController.userData?.sId,
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        mobile: mobileController.text.trim(),
      );
      await AuthController.updateUserData(model);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update profile. Please try again.'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await AuthController.cleanUserData();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = [
      firstNameController.text.trim().isNotEmpty
          ? firstNameController.text.trim()[0].toUpperCase()
          : '',
      lastNameController.text.trim().isNotEmpty
          ? lastNameController.text.trim()[0].toUpperCase()
          : '',
    ].join();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile settings'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ScreenBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .90),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE8EEF4)),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: kPrimary.withValues(alpha: .12),
                          child: Text(
                            initials.isEmpty ? 'U' : initials,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
                                  .trim()
                                  .isEmpty
                              ? 'Your profile'
                              : '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
                                    .trim(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emailController.text.trim(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Personal information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel(label: 'Email address'),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty || !text.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: 'First name'),
                  TextFormField(
                    controller: firstNameController,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Enter your first name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'First name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: 'Last name'),
                  TextFormField(
                    controller: lastNameController,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Enter your last name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: 'Mobile number'),
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter your mobile number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Security',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel(label: 'New password (optional)'),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Leave blank to keep your current password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : updateProfile,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      isSubmitting ? 'Saving changes...' : 'Save changes',
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
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
      ),
    );
  }
}
