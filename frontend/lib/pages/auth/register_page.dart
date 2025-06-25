import 'dart:ui'; // Diperlukan untuk ImageFilter.blur

import 'package:d_button/d_button.dart';
import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_assets.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_response.dart';
import '../../config/failure.dart';
import '../../datasources/user_datasource.dart';
import '../../providers/register_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final edtUsername = TextEditingController();
  final edtEmail = TextEditingController();
  final edtPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // State untuk kontrol visibilitas password
  bool isPasswordVisible = false;

  @override
  void dispose() {
    edtUsername.dispose();
    edtEmail.dispose();
    edtPassword.dispose();
    super.dispose();
  }

  // --- LOGIKA TIDAK DIUBAH SAMA SEKALI ---
  execute() {
    bool validInput = formKey.currentState!.validate();
    if (!validInput) return;

    setRegisterStatus(ref, 'Loading');

    UserDatasource.register(
      edtUsername.text,
      edtEmail.text,
      edtPassword.text,
    ).then((value) {
      String newStatus = '';

      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case ServerFailure:
              newStatus = 'Server Error';
              DInfo.toastError(newStatus);
              break;
            case NotFoundFailure:
              newStatus = 'Error Not Found';
              DInfo.toastError(newStatus);
              break;
            case ForbiddenFailure:
              newStatus = "You don't have access";
              DInfo.toastError(newStatus);
              break;
            case BadRequestFailure:
              newStatus = 'Bad request';
              DInfo.toastError(newStatus);
              break;
            case InvalidInputFailure:
              newStatus = 'Invalid Input';
              AppResponse.invalidInput(context, failure.message ?? '{}');
              break;
            case UnauthorisedFailure:
              newStatus = 'Unauthorised';
              DInfo.toastError(newStatus);
              break;
            default:
              newStatus = 'Request Error';
              DInfo.toastError(newStatus);
              newStatus = failure.message ?? '-';
              break;
          }
          setRegisterStatus(ref, newStatus);
        },
        (result) {
          DInfo.toastSuccess('Register Success. Please Login.');
          setRegisterStatus(ref, 'Success');
          // Kembali ke halaman login setelah berhasil register
          Navigator.pop(context);
        },
      );
    });
  }
  // --- END OF LOGIC ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            AppAssets.bgAuth,
            fit: BoxFit.cover,
          ),
          // 2. Tombol Kembali
          _buildBackButton(context),
          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildGlassmorphismForm(),
                  const SizedBox(height: 30),
                  _buildLoginRedirect(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Tombol Kembali ke Halaman Sebelumnya
  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 10,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Login',
        ),
      ),
    );
  }

  // Widget untuk Header (Judul & Subjudul)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.montserrat(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            shadows: [
              const Shadow(
                blurRadius: 10.0,
                color: Colors.black45,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s get started with your new account',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget untuk Form dengan efek "Frosted Glass"
  Widget _buildGlassmorphismForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUsernameField(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 25),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk Input Field (DRY - Don't Repeat Yourself)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: isPassword ? !isPasswordVisible : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      controller: edtUsername,
      label: 'Username',
      icon: Icons.person_outline,
      validator: (input) => input == '' ? "Username cannot be empty" : null,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: edtEmail,
      label: 'Email',
      icon: Icons.email_outlined,
      validator: (input) => input == '' ? "Email cannot be empty" : null,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: edtPassword,
      label: 'Password',
      icon: Icons.lock_outline,
      isPassword: true,
      validator: (input) => input == '' ? "Password cannot be empty" : null,
    );
  }

  // Widget untuk Tombol Register
  Widget _buildRegisterButton() {
    return Consumer(builder: (_, wiRef, __) {
      String status = wiRef.watch(registerStatusProvider);
      if (status == 'Loading') {
        return Center(child: DView.loadingCircle());
      }
      return SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () => execute(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Create Account'),
        ),
      );
    });
  }

  // Widget untuk Navigasi ke Halaman Login
  Widget _buildLoginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
