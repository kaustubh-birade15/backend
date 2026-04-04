import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // Production Backend URL on Render
  static const String _productionUrl = "https://backend-1-lovz.onrender.com";

  static String get baseUrl {
    // ⬇️ SET TO true FOR LOCAL TESTING (Laptop must be on)
    // ⬇️ SET TO false FOR REMOTE ACCESS (Production Render)
    const bool useLocal = false; // Set to false to use your Live Cloud URL!

    if (useLocal) {
      if (kIsWeb) return "http://localhost:8000";
      try {
        if (Platform.isAndroid) {
          // Since you're using a real phone, we use your laptop's Wi-Fi IP
          return "http://192.168.0.100:8000"; 
        }
      } catch (_) {}
      return "http://127.0.0.1:8000";
    }

    return _productionUrl;
  }

  static const Duration _timeout = Duration(seconds: 60);

  // Auth: Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? "Failed to login");
    }
  }

  // Auth: Register
  static Future<Map<String, dynamic>> register(Map<String, dynamic> patientData) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(patientData),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? "Failed to register");
    }
  }

  // Retrieve History
  static Future<Map<String, dynamic>> getHistory(int patientId) async {
    final url = Uri.parse("$baseUrl/history/$patientId");
    final response = await http.get(url).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch history");
    }
  }

  // Get Patient Profile Data
  static Future<Map<String, dynamic>> getPatientInfo(int patientId) async {
    final url = Uri.parse("$baseUrl/patient/$patientId");
    final response = await http.get(url).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch profile");
    }
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword(int patientId, String oldPassword, String newPassword) async {
    final url = Uri.parse("$baseUrl/change_password/$patientId");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? "Failed to change password");
    }
  }

  // Get Prediction
  static Future<Map<String, dynamic>> getPrediction(List<String> symptoms, {int? patientId, String severity = "moderate"}) async {
    var urlString = "$baseUrl/predict";
    if (patientId != null) {
      urlString += "?patient_id=$patientId";
    }
    final url = Uri.parse(urlString);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "symptoms": symptoms,
        "severity": severity,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Map<String, dynamic>.from(decoded);
    } else {
      throw Exception("Failed to fetch prediction: ${response.body}");
    }
  }

  // Update Medical Conditions
  static Future<Map<String, dynamic>> updatePatientConditions(int patientId, String conditions) async {
    final url = Uri.parse("$baseUrl/patient/$patientId/conditions");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"conditions": conditions}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? "Failed to update conditions");
    }
  }

  // New Consult Method (Step 2 equivalent)
  static Future<Map<String, dynamic>> consult({
    required String userId,
    required String symptom,
    required String severity,
  }) async {
    final url = Uri.parse("$baseUrl/consult");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id":  userId,
        "symptom":  symptom,
        "severity": severity,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Map<String, dynamic>.from(decoded);
    } else {
      throw Exception("Consultation failed: ${response.body}");
    }
  }
}