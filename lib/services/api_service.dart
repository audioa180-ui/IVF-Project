import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ivf_patient_app/models/user.dart';
import 'package:ivf_patient_app/models/doctor.dart';
import 'package:ivf_patient_app/models/appointment.dart';
import 'package:ivf_patient_app/models/blog.dart';

class ApiService {
  static String _baseUrl = 'http://localhost:4000/api';

  static void setBaseUrl(String url) => _baseUrl = url;

  String? _token;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  void setToken(String? token) => _token = token;

  Future<dynamic> _handleResponse(http.Response res) async {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(body['error'] ?? 'Request failed', res.statusCode);
  }

  Future<User> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handleResponse(res);
    _token = data['token'];
    return User.fromJson(data['user']);
  }

  Future<User> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = await _handleResponse(res);
    _token = data['token'];
    return User.fromJson(data['user']);
  }

  Future<User> getMe() async {
    final res = await http.get(Uri.parse('$_baseUrl/users/me'), headers: _headers);
    final data = await _handleResponse(res);
    return User.fromJson(data);
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final res = await http.put(Uri.parse('$_baseUrl/users/me'), headers: _headers, body: jsonEncode(updates));
    final data = await _handleResponse(res);
    return User.fromJson(data);
  }

  Future<List<Doctor>> getDoctors({String? search}) async {
    final uri = Uri.parse('$_baseUrl/doctors').replace(queryParameters: search != null ? {'search': search} : null);
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data.map((d) => Doctor.fromJson(d)).toList();
  }

  Future<Doctor> getDoctor(String id) async {
    final res = await http.get(Uri.parse('$_baseUrl/doctors/$id'), headers: _headers);
    final data = await _handleResponse(res);
    return Doctor.fromJson(data);
  }

  Future<List<Appointment>> getAppointments() async {
    final res = await http.get(Uri.parse('$_baseUrl/appointments'), headers: _headers);
    final data = await _handleResponse(res) as List;
    return data.map((a) => Appointment.fromJson(a)).toList();
  }

  Future<Appointment> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String clinic,
    required DateTime date,
    required String time,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/appointments'),
      headers: _headers,
      body: jsonEncode({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'clinic': clinic,
        'date': date.toIso8601String(),
        'time': time,
      }),
    );
    final data = await _handleResponse(res);
    return Appointment.fromJson(data);
  }

  Future<void> cancelAppointment(String id) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/appointments/$id'),
      headers: _headers,
      body: jsonEncode({'status': 'cancelled'}),
    );
    await _handleResponse(res);
  }

  Future<void> rescheduleAppointment(String id, DateTime newDate, String newTime) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/appointments/$id'),
      headers: _headers,
      body: jsonEncode({'date': newDate.toIso8601String(), 'time': newTime, 'status': 'upcoming'}),
    );
    await _handleResponse(res);
  }

  Future<List<Blog>> getBlogs({String? search, String? category}) async {
    final params = <String, String>{};
    if (search != null) params['search'] = search;
    if (category != null) params['category'] = category;
    final uri = Uri.parse('$_baseUrl/blogs').replace(queryParameters: params.isNotEmpty ? params : null);
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data.map((b) => Blog.fromJson(b)).toList();
  }

  Future<Blog> getBlog(String id) async {
    final res = await http.get(Uri.parse('$_baseUrl/blogs/$id'), headers: _headers);
    final data = await _handleResponse(res);
    return Blog.fromJson(data);
  }

  Future<Map<String, dynamic>> toggleLikeBlog(String blogId) async {
    final res = await http.post(Uri.parse('$_baseUrl/blogs/$blogId/like'), headers: _headers);
    return await _handleResponse(res);
  }

  Future<Map<String, dynamic>> toggleSaveBlog(String blogId) async {
    final res = await http.post(Uri.parse('$_baseUrl/blogs/$blogId/save'), headers: _headers);
    return await _handleResponse(res);
  }

  Future<Map<String, dynamic>> getBlogPreferences() async {
    final res = await http.get(Uri.parse('$_baseUrl/blogs/user/preferences'), headers: _headers);
    return await _handleResponse(res);
  }

  Future<List<dynamic>> getClinics() async {
    final res = await http.get(Uri.parse('$_baseUrl/data/clinics'));
    return await _handleResponse(res) as List;
  }

  Future<List<dynamic>> getTreatmentSteps() async {
    final res = await http.get(Uri.parse('$_baseUrl/data/treatment-steps'));
    return await _handleResponse(res) as List;
  }

  Future<List<dynamic>> getDailyTips() async {
    final res = await http.get(Uri.parse('$_baseUrl/data/daily-tips'));
    return await _handleResponse(res) as List;
  }

  Future<List<dynamic>> getFaqs() async {
    final res = await http.get(Uri.parse('$_baseUrl/data/faqs'));
    return await _handleResponse(res) as List;
  }

  Future<List<String>> getCategories() async {
    final res = await http.get(Uri.parse('$_baseUrl/data/categories'));
    return List<String>.from(await _handleResponse(res) as List);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
