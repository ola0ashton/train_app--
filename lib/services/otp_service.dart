// ignore_for_file: depend_on_referenced_packages

import 'package:supabase_flutter/supabase_flutter.dart';

class OtpService {
  Future<bool> sendOtp(String email) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'send-otp',
        body: {'email': email},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'verify-otp',
        body: {'email': email, 'otp': otp},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
