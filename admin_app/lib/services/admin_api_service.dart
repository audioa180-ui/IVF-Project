import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_app/config/api_config.dart';

class AdminApiService {
  static final String _baseUrl = '${ApiConfig.apiUrl}/admin';
  
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
    throw AdminApiException(body['error'] ?? 'Request failed', res.statusCode);
  }
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handleResponse(res);
    _token = data['token'];
    return data;
  }
  
  // Get Dashboard Stats
  Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(Uri.parse('$_baseUrl/dashboard'), headers: _headers);
    return await _handleResponse(res);
  }
  
  // Get All Users
  Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('$_baseUrl/users'), headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get User Details
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final res = await http.get(Uri.parse('$_baseUrl/users/$userId'), headers: _headers);
    return await _handleResponse(res);
  }
  
  // Get All Appointments
  Future<List<dynamic>> getAppointments() async {
    final res = await http.get(Uri.parse('$_baseUrl/appointments'), headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get All Appointments with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllAppointments({
    String? doctorId,
    String? userId,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (doctorId != null) 'doctorId': doctorId,
      // ignore: use_null_aware_elements
      if (userId != null) 'userId': userId,
      // ignore: use_null_aware_elements
      if (status != null) 'status': status,
      // ignore: use_null_aware_elements
      if (startDate != null) 'startDate': startDate,
      // ignore: use_null_aware_elements
      if (endDate != null) 'endDate': endDate,
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/appointments/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Update Appointment Status (Admin)
  Future<Map<String, dynamic>> updateAppointmentStatus(String appointmentId, String status) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/appointments/admin/$appointmentId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return await _handleResponse(res);
  }
  
  // Get Appointment Statistics (Admin)
  Future<Map<String, dynamic>> getAppointmentStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/appointments/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Patients with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllPatients({
    String? search,
    String? status,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (search != null) 'search': search,
      // ignore: use_null_aware_elements
      if (status != null) 'status': status,
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/patients/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get Patient Details (Admin)
  Future<Map<String, dynamic>> getPatientDetails(String patientId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/patients/admin/$patientId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get Patient Statistics (Admin)
  Future<Map<String, dynamic>> getPatientStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/patients/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Treatment Cycles with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllTreatmentCycles({
    String? status,
    String? cycleType,
    String? doctorId,
    String? patientId,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (status != null) 'status': status,
      // ignore: use_null_aware_elements
      if (cycleType != null) 'cycleType': cycleType,
      // ignore: use_null_aware_elements
      if (doctorId != null) 'doctorId': doctorId,
      // ignore: use_null_aware_elements
      if (patientId != null) 'patientId': patientId,
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/treatmentCycles/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get Treatment Cycle Details (Admin)
  Future<Map<String, dynamic>> getTreatmentCycleDetails(String cycleId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/treatmentCycles/admin/$cycleId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Update Treatment Cycle Status (Admin)
  Future<Map<String, dynamic>> updateTreatmentCycleStatus(String cycleId, String status) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/treatmentCycles/admin/$cycleId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return await _handleResponse(res);
  }
  
  // Get Treatment Cycle Statistics (Admin)
  Future<Map<String, dynamic>> getTreatmentCycleStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/treatmentCycles/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Lab Results with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllLabResults({
    String? patientId,
    String? testType,
    String? testCategory,
    bool? isAbnormal,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (patientId != null) 'patientId': patientId,
      // ignore: use_null_aware_elements
      if (testType != null) 'testType': testType,
      // ignore: use_null_aware_elements
      if (testCategory != null) 'testCategory': testCategory,
      if (isAbnormal != null) 'isAbnormal': isAbnormal.toString(),
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/labResults/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get Lab Result Details (Admin)
  Future<Map<String, dynamic>> getLabResultDetails(String resultId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/labResults/admin/$resultId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Review Lab Result (Admin)
  Future<Map<String, dynamic>> reviewLabResult(String resultId, String reviewedBy, String reviewNotes) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/labResults/admin/$resultId/review'),
      headers: _headers,
      body: jsonEncode({
        'reviewedBy': reviewedBy,
        'reviewNotes': reviewNotes,
      }),
    );
    return await _handleResponse(res);
  }
  
  // Get Lab Result Statistics (Admin)
  Future<Map<String, dynamic>> getLabResultStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/labResults/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Medications with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllMedications({
    String? category,
    bool? isActive,
    bool? lowStock,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (category != null) 'category': category,
      if (isActive != null) 'isActive': isActive.toString(),
      if (lowStock != null) 'lowStock': lowStock.toString(),
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/medications/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get Medication Details (Admin)
  Future<Map<String, dynamic>> getMedicationDetails(String medicationId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/medications/admin/$medicationId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Update Medication Stock (Admin)
  Future<Map<String, dynamic>> updateMedicationStock(String medicationId, int stock) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/medications/admin/$medicationId/stock'),
      headers: _headers,
      body: jsonEncode({'stock': stock}),
    );
    return await _handleResponse(res);
  }
  
  // Get Medication Statistics (Admin)
  Future<Map<String, dynamic>> getMedicationStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/medications/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Invoices with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllInvoices({
    String? patientId,
    String? paymentStatus,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (patientId != null) 'patientId': patientId,
      // ignore: use_null_aware_elements
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      // ignore: use_null_aware_elements
      if (startDate != null) 'startDate': startDate,
      // ignore: use_null_aware_elements
      if (endDate != null) 'endDate': endDate,
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/invoices/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get Invoice Details (Admin)
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/invoices/admin/$invoiceId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Update Invoice Payment (Admin)
  Future<Map<String, dynamic>> updateInvoicePayment(String invoiceId, String paymentStatus, double paidAmount) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/invoices/admin/$invoiceId/payment'),
      headers: _headers,
      body: jsonEncode({
        'paymentStatus': paymentStatus,
        'paidAmount': paidAmount,
      }),
    );
    return await _handleResponse(res);
  }
  
  // Get Invoice Statistics (Admin)
  Future<Map<String, dynamic>> getInvoiceStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/invoices/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Doctors with Filters (Admin)
  // ignore: use_null_aware_elements
  Future<List<dynamic>> getAllDoctors({
    String? specialization,
    bool? availableToday,
  }) async {
    final queryParams = <String, String>{
      // ignore: use_null_aware_elements
      if (specialization != null) 'specialization': specialization,
      if (availableToday != null) 'availableToday': availableToday.toString(),
    };
    
    final uri = Uri.parse('${ApiConfig.apiUrl}/doctors/admin/all')
        .replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Get Doctor Details (Admin)
  Future<Map<String, dynamic>> getDoctorDetails(String doctorId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/doctors/admin/$doctorId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Create Doctor (Admin)
  Future<Map<String, dynamic>> createDoctor(Map<String, dynamic> doctorData) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/doctors/admin'),
      headers: _headers,
      body: jsonEncode(doctorData),
    );
    return await _handleResponse(res);
  }
  
  // Update Doctor (Admin)
  Future<Map<String, dynamic>> updateDoctor(String doctorId, Map<String, dynamic> doctorData) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/doctors/admin/$doctorId'),
      headers: _headers,
      body: jsonEncode(doctorData),
    );
    return await _handleResponse(res);
  }
  
  // Delete Doctor (Admin)
  Future<Map<String, dynamic>> deleteDoctor(String doctorId) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.apiUrl}/doctors/admin/$doctorId'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get Doctor Statistics (Admin)
  Future<Map<String, dynamic>> getDoctorStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/doctors/admin/stats'),
      headers: _headers,
    );
    return await _handleResponse(res);
  }
  
  // Get All Admins (Master only)
  Future<List<dynamic>> getAdmins() async {
    final res = await http.get(Uri.parse('$_baseUrl/admins'), headers: _headers);
    final data = await _handleResponse(res) as List;
    return data;
  }
  
  // Create Admin (Master only)
  Future<Map<String, dynamic>> createAdmin(Map<String, dynamic> adminData) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/admins'),
      headers: _headers,
      body: jsonEncode(adminData),
    );
    return await _handleResponse(res);
  }
  
  // Update Admin (Master only)
  Future<Map<String, dynamic>> updateAdmin(String adminId, Map<String, dynamic> adminData) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/admins/$adminId'),
      headers: _headers,
      body: jsonEncode(adminData),
    );
    return await _handleResponse(res);
  }
  
  // Delete Admin (Master only)
  Future<void> deleteAdmin(String adminId) async {
    final res = await http.delete(Uri.parse('$_baseUrl/admins/$adminId'), headers: _headers);
    await _handleResponse(res);
  }
}

class AdminApiException implements Exception {
  final String message;
  final int statusCode;
  AdminApiException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}
