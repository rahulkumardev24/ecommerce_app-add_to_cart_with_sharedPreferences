import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  /// password check
  bool _isVisible = false;
  /// loading check
  bool _isLoading = false;
  /// form key
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    /// loading show
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    /// here check email and password both field is need
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', _emailController.text);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please enter valid credentials",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    /// loading close
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// here we dispose the controller
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// login image
                SvgPicture.asset(
                  height: size.height * 0.4,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  "lib/assets/image/login_image.svg",
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 27,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alternate_email_rounded,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: "Email ID",
                                hintStyle: TextStyle(color: Colors.black54),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 21),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isVisible,
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.black54),
                                suffixIcon: InkWell(
                                  onTap: (){
                                    setState(() {
                                      _isVisible = !_isVisible ;
                                    });
                                  },
                                  child: Icon(
                                  !_isVisible ?  Icons.visibility_off_rounded : Icons.visibility,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),

                      /// Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),

                      /// Login button
                      SizedBox(
                        width: size.width,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21,
                                      ),
                                    ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      /// Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black38)),
                          SizedBox(width: 21),
                          Text(
                            "OR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black26,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(width: 21),
                          Expanded(child: Divider(color: Colors.black38)),
                        ],
                      ),

                      SizedBox(height: size.height * 0.02),

                      /// Login with Google
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.blue.shade50.withAlpha(150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "lib/assets/image/google.png",
                                width: 30,
                                height: 30,
                              ),
                              SizedBox(width: 21),
                              Text(
                                "Login with Google",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to Logistics?",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _emailController.text = 'test@example.com';
                              _passwordController.text = 'password123';
                              _login();
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
