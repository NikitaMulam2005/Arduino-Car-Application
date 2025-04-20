
import 'package:http/http.dart' as http;
import 'dart:convert';

final baseurl='http://192.168.182.223:3000';
Future<bool> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseurl/api/auth/login'), // Replace with your IP or domain
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    // Optionally parse token or user data
    return true;
  } else {
    print('Login failed: ${response.body}');
    return false;
  }
}


Future<bool> signup(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseurl/api/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 201) {
    return true;
  } else {
    print('Signup failed: ${response.body}');
    return false;
  }
}