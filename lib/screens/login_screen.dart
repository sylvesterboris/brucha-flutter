import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isOtpStage = false;
  bool _isLoading = false;
  int _resendCountdown = 30;
  Timer? _timer;
  String? _phoneError;
  String? _otpError;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _autofill(String phone) {
    HapticFeedback.lightImpact();
    setState(() {
      _phoneController.text = phone;
      _phoneError = null;
    });
    // Request focus on the next frame to prevent layout issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      HapticFeedback.vibrate();
      setState(() {
        _phoneError = 'Please enter a valid 10-digit number';
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _phoneError = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isOtpStage = true;
      _otpController.clear();
      _otpError = null;
    });

    _startTimer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🔑', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'Simulated OTP sent! (Use code: 1234)',
              style: GoogleFonts.jost(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: BruchaColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp != '1234') {
      HapticFeedback.vibrate();
      setState(() {
        _otpError = 'Invalid OTP. Please enter 1234 to log in.';
      });
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    // Determine role based on mock credentials
    final phone = _phoneController.text.trim();
    UserRole role;
    if (phone == '9999999999') {
      role = UserRole.admin;
    } else if (phone == '8888888888') {
      role = UserRole.staff;
    } else {
      role = UserRole.customer;
    }

    // Login logic using app provider
    final app = context.read<AppProvider>();
    await app.login(phone, role);

    // Simulate slight verification delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate to menu screen and remove all back routes
    Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
  }

  void _backToPhone() {
    HapticFeedback.lightImpact();
    setState(() {
      _isOtpStage = false;
      _otpController.clear();
      _otpError = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isMatcha = app.themeFlavor == ThemeFlavor.matcha;

    return Scaffold(
      backgroundColor: BruchaColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Branding / Logo
              Center(
                child: Hero(
                  tag: 'app_logo',
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BruchaColors.gold.withOpacity(0.2),
                            width: 1,
                          ),
                          color: BruchaColors.ink2.withOpacity(0.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isMatcha ? '🍵' : '☕',
                          style: const TextStyle(fontSize: 38),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Brucha',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: BruchaColors.gold2,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'SLOW FOOD. GOOD COFFEE.',
                        style: GoogleFonts.jost(
                          fontSize: 10,
                          color: BruchaColors.gold.withOpacity(0.6),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Form Stage Container with Custom Transition Animation
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isOtpStage ? _buildOtpStage(app) : _buildPhoneStage(),
              ),

              const SizedBox(height: 36),

              // Mock Accounts helper panel
              _buildMockAccountsPanel(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mobile Login',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: BruchaColors.cream,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with your mobile number to view personalized menus, track loyalty points, and place tableside orders.',
          style: GoogleFonts.jost(
            fontSize: 13,
            color: BruchaColors.parch3.withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        // Phone Input
        TextFormField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.jost(
            color: BruchaColors.cream,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: Icon(
              Icons.phone_iphone_rounded,
              color: BruchaColors.gold2,
              size: 20,
            ),
            prefixText: '+91 ',
            prefixStyle: GoogleFonts.jost(
              color: BruchaColors.gold3,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            hintText: 'Enter phone number',
            hintStyle: GoogleFonts.jost(
              color: BruchaColors.ink3.withOpacity(0.8),
              fontSize: 15,
              letterSpacing: 1,
            ),
            fillColor: BruchaColors.ink2.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BruchaColors.ink3.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BruchaColors.gold, width: 1.5),
            ),
            errorText: _phoneError,
            errorStyle: GoogleFonts.jost(
              color: Colors.redAccent,
              fontSize: 11,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (val) {
            if (_phoneError != null) {
              setState(() => _phoneError = null);
            }
          },
          onFieldSubmitted: (_) => _sendOtp(),
        ),
        const SizedBox(height: 24),
        // Button
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: BruchaColors.gold,
            foregroundColor: BruchaColors.ink,
            disabledBackgroundColor: BruchaColors.gold.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'SEND OTP',
                  style: GoogleFonts.jost(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: BruchaColors.ink,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOtpStage(AppProvider app) {
    final otpText = _otpController.text;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verification Code',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: BruchaColors.cream,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Code sent to +91 ${_phoneController.text}',
              style: GoogleFonts.jost(
                fontSize: 13,
                color: BruchaColors.parch3.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _isLoading ? null : _backToPhone,
              child: Text(
                'Edit',
                style: GoogleFonts.jost(
                  fontSize: 13,
                  color: BruchaColors.gold2,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Hidden input with custom UI pins
        Stack(
          alignment: Alignment.center,
          children: [
            // Secret textfield
            Opacity(
              opacity: 0,
              child: TextFormField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (val) {
                  setState(() {
                    _otpError = null;
                  });
                  if (val.length == 4) {
                    _verifyOtp();
                  }
                },
              ),
            ),
            // Custom boxes row
            GestureDetector(
              onTap: () {
                _otpFocusNode.requestFocus();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  String digit = '';
                  if (otpText.length > index) {
                    digit = otpText[index];
                  }
                  bool isFocused = _otpFocusNode.hasFocus && otpText.length == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 54,
                    height: 58,
                    decoration: BoxDecoration(
                      color: BruchaColors.ink2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFocused
                            ? BruchaColors.gold
                            : _otpError != null
                                ? Colors.redAccent
                                : BruchaColors.ink3.withOpacity(0.5),
                        width: isFocused ? 2.0 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      digit,
                      style: GoogleFonts.jost(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: BruchaColors.gold2,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        if (_otpError != null) ...[
          const SizedBox(height: 12),
          Text(
            _otpError!,
            style: GoogleFonts.jost(
              color: Colors.redAccent,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 24),

        // Countdown Timer / Resend Button
        Center(
          child: _resendCountdown > 0
              ? Text(
                  'Resend OTP in ${_resendCountdown}s',
                  style: GoogleFonts.jost(
                    fontSize: 13,
                    color: BruchaColors.parch3.withOpacity(0.5),
                  ),
                )
              : TextButton(
                  onPressed: _isLoading ? null : () {
                    _otpController.clear();
                    _otpError = null;
                    _startTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'OTP Resent! (Use code: 1234)',
                          style: GoogleFonts.jost(fontSize: 13),
                        ),
                        backgroundColor: BruchaColors.gold,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'RESEND OTP',
                    style: GoogleFonts.jost(
                      fontSize: 13,
                      color: BruchaColors.gold2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: BruchaColors.gold,
            foregroundColor: BruchaColors.ink,
            disabledBackgroundColor: BruchaColors.gold.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'VERIFY & LOGIN',
                  style: GoogleFonts.jost(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: BruchaColors.ink,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMockAccountsPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BruchaColors.ink2.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BruchaColors.gold.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: BruchaColors.gold2,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Demo Guest Accounts',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: BruchaColors.gold2,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tap on any preset card below to autofill and test its role separation immediately.',
            style: GoogleFonts.jost(
              fontSize: 11,
              color: BruchaColors.parch3.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Demo account grid / list
          _buildDemoTile(
            phone: '9999999999',
            roleName: 'System Administrator',
            desc: 'Sales stats, menu controls, table QR codes & kitchen logs',
            icon: Icons.admin_panel_settings_outlined,
          ),
          const SizedBox(height: 10),
          _buildDemoTile(
            phone: '8888888888',
            roleName: 'Kitchen Staff',
            desc: 'Real-time order ticket updates and kitchen queue',
            icon: Icons.kitchen_outlined,
          ),
          const SizedBox(height: 10),
          _buildDemoTile(
            phone: '1234567890',
            roleName: 'Customer',
            desc: 'Menu ordering, tableside waiter bell & bill splitting',
            icon: Icons.restaurant_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoTile({
    required String phone,
    required String roleName,
    required String desc,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _autofill(phone),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BruchaColors.ink.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: BruchaColors.ink3.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: BruchaColors.ink2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: BruchaColors.gold3,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        roleName,
                        style: GoogleFonts.jost(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BruchaColors.cream,
                        ),
                      ),
                      Text(
                        phone,
                        style: GoogleFonts.jost(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: BruchaColors.gold2,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: GoogleFonts.jost(
                      fontSize: 10,
                      color: BruchaColors.parch3.withOpacity(0.5),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
