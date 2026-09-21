import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/db_helper.dart';
import '../services/pin_controller.dart';
import '../theme/app_theme.dart';

/// Layar wajib PIN saat aplikasi dibuka. Tidak bisa di-lewati (no back).
class PinLoginPage extends StatefulWidget {
  final VoidCallback onSuccess;
  const PinLoginPage({super.key, required this.onSuccess});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final _controller = TextEditingController();
  bool _busy = false;
  String _error = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _controller.text.trim();
    if (pin.length < PinController.minLength) {
      setState(() => _error = 'PIN minimal 4 digit');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    // PIN diverifikasi terhadap cloud (tersinkronisasi antar perangkat),
    // fallback ke cache lokal bila offline.
    final ok = await DbHelper.instance.verifyPin(pin);
    if (!mounted) return;
    if (ok) {
      widget.onSuccess();
    } else {
      setState(() {
        _busy = false;
        _error = 'PIN salah, coba lagi';
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.heroGrad1, c.heroGrad2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_outline,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text('Inventaris Spek Komputer',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20)),
                  const SizedBox(height: 6),
                  Text('Masukkan PIN untuk membuka aplikasi',
                      style: TextStyle(color: c.textMuted, fontSize: 13)),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                            PinController.maxLength),
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 26,
                          letterSpacing: 12,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: c.surface,
                        hintText: '••••',
                        hintStyle: TextStyle(
                            color: c.inputHint, letterSpacing: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: c.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: c.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: c.accent, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_error.isNotEmpty)
                    Text(_error,
                        style: TextStyle(color: c.danger, fontSize: 13)),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: c.accent,
                      foregroundColor: c.onAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _busy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: c.onAccent))
                        : const Text('Buka Aplikasi',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
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