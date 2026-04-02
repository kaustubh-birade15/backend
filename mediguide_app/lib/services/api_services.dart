import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // Production Backend URL on Render
  static const String _productionUrl = "https://backend-txn1.onrender.com";

  static String get baseUrl {
    // ⬇️ FOR REMOTE ACCESS (Phone anywhere), use this:
    return _productionUrl;

    // // ⬇️ FOR LOCAL TESTING (Laptop must be on), use this instead:
    // if (kIsWeb) return "http://localhost:8000";
    // try {
    //   if (Platform.isAndroid) return "http://10.0.2.2:8000";
    // } catch (_) { }
    // return "http://127.0.0.1:8000"; 
  }

  static const Duration _timeout = Duration(seconds: 10);

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
  static Future<Map<String, dynamic>> getPrediction(List<String> symptoms, {int? patientId}) async {
    var urlString = "$baseUrl/predict";
    if (patientId != null) {
      urlString += "?patient_id=$patientId";
    }
    final url = Uri.parse(urlString);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"symptoms": symptoms}),
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
}