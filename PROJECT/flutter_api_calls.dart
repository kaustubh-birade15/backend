import 'dart:convert';

Future registerPatient() async {
  final url = Uri.parse("http://YOUR_IP:8080/patient/register");

  var http;
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json"
    },
    body: jsonEncode({
      "user_id": "user123",
      "name": "Aaryan",
      "age": 22,
      "gender": "male",
      "blood_group": "B+",
      "bp_high": false,
      "diabetic": false,
      "sugar_level": "normal",
      "bp_reading": "",
      "allergies": [],
      "existing_conditions": [],
      "current_medications": []
    }),
  );

  print(response.body);
}