import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_app/services/admin_api_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  
  Map<String, dynamic>? _admin;
  Map<String, dynamic>? get admin => _admin;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  
  // Initialize provider
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    final adminData = prefs.getString('admin_data');
    
    if (token != null && adminData != null) {
      _apiService.setToken(token);
      _admin = jsonDecode(adminData);
      _isAuthenticated = true;
      notifyListeners();
    }
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(email, password);
      _admin = response['admin'];
      _apiService.setToken(response['token']);
      _isAuthenticated = true;
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', response['token']);
      await prefs.setString('admin_data', jsonEncode(_admin));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _admin = null;
    _apiService.setToken(null);
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_data');
    
    notifyListeners();
  }
  
  // Get Dashboard Data
  Future<Map<String, dynamic>?> getDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getDashboard();
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Get Users
  Future<List<dynamic>?> getUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final users = await _apiService.getUsers();
      _isLoading = false;
      notifyListeners();
      return users;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Get User Details
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getUserDetails(userId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Get Appointments
  Future<List<dynamic>?> getAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final appointments = await _apiService.getAppointments();
      _isLoading = false;
      notifyListeners();
      return appointments;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Get All Appointments with Filters (Admin)
  Future<List<dynamic>> getAllAppointments({
    String? doctorId,
    String? userId,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final appointments = await _apiService.getAllAppointments(
        doctorId: doctorId,
        userId: userId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      _isLoading = false;
      notifyListeners();
      return appointments;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Update Appointment Status (Admin)
  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateAppointmentStatus(appointmentId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get Appointment Statistics (Admin)
  Future<Map<String, dynamic>> getAppointmentStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getAppointmentStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get All Patients with Filters (Admin)
  Future<List<dynamic>> getAllPatients({
    String? search,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final patients = await _apiService.getAllPatients(
        search: search,
        status: status,
      );
      _isLoading = false;
      notifyListeners();
      return patients;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get Patient Details (Admin)
  Future<Map<String, dynamic>> getPatientDetails(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getPatientDetails(patientId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get Patient Statistics (Admin)
  Future<Map<String, dynamic>> getPatientStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getPatientStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get All Treatment Cycles with Filters (Admin)
  Future<List<dynamic>> getAllTreatmentCycles({
    String? status,
    String? cycleType,
    String? doctorId,
    String? patientId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final cycles = await _apiService.getAllTreatmentCycles(
        status: status,
        cycleType: cycleType,
        doctorId: doctorId,
        patientId: patientId,
      );
      _isLoading = false;
      notifyListeners();
      return cycles;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get Treatment Cycle Details (Admin)
  Future<Map<String, dynamic>> getTreatmentCycleDetails(String cycleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getTreatmentCycleDetails(cycleId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Update Treatment Cycle Status (Admin)
  Future<bool> updateTreatmentCycleStatus(String cycleId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateTreatmentCycleStatus(cycleId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get Treatment Cycle Statistics (Admin)
  Future<Map<String, dynamic>> getTreatmentCycleStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getTreatmentCycleStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get All Lab Results with Filters (Admin)
  Future<List<dynamic>> getAllLabResults({
    String? patientId,
    String? testType,
    String? testCategory,
    bool? isAbnormal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final results = await _apiService.getAllLabResults(
        patientId: patientId,
        testType: testType,
        testCategory: testCategory,
        isAbnormal: isAbnormal,
      );
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get Lab Result Details (Admin)
  Future<Map<String, dynamic>> getLabResultDetails(String resultId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getLabResultDetails(resultId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Review Lab Result (Admin)
  Future<bool> reviewLabResult(String resultId, String reviewedBy, String reviewNotes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.reviewLabResult(resultId, reviewedBy, reviewNotes);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get Lab Result Statistics (Admin)
  Future<Map<String, dynamic>> getLabResultStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getLabResultStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get All Medications with Filters (Admin)
  Future<List<dynamic>> getAllMedications({
    String? category,
    bool? isActive,
    bool? lowStock,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final medications = await _apiService.getAllMedications(
        category: category,
        isActive: isActive,
        lowStock: lowStock,
      );
      _isLoading = false;
      notifyListeners();
      return medications;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get Medication Details (Admin)
  Future<Map<String, dynamic>> getMedicationDetails(String medicationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getMedicationDetails(medicationId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Update Medication Stock (Admin)
  Future<bool> updateMedicationStock(String medicationId, int stock) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateMedicationStock(medicationId, stock);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get Medication Statistics (Admin)
  Future<Map<String, dynamic>> getMedicationStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getMedicationStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get All Invoices with Filters (Admin)
  Future<List<dynamic>> getAllInvoices({
    String? patientId,
    String? paymentStatus,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final invoices = await _apiService.getAllInvoices(
        patientId: patientId,
        paymentStatus: paymentStatus,
        startDate: startDate,
        endDate: endDate,
      );
      _isLoading = false;
      notifyListeners();
      return invoices;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get Invoice Details (Admin)
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getInvoiceDetails(invoiceId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Update Invoice Payment (Admin)
  Future<bool> updateInvoicePayment(String invoiceId, String paymentStatus, double paidAmount) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateInvoicePayment(invoiceId, paymentStatus, paidAmount);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get Invoice Statistics (Admin)
  Future<Map<String, dynamic>> getInvoiceStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getInvoiceStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get All Doctors with Filters (Admin)
  Future<List<dynamic>> getAllDoctors({
    String? specialization,
    bool? availableToday,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final doctors = await _apiService.getAllDoctors(
        specialization: specialization,
        availableToday: availableToday,
      );
      _isLoading = false;
      notifyListeners();
      return doctors;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get Doctor Details (Admin)
  Future<Map<String, dynamic>> getDoctorDetails(String doctorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final data = await _apiService.getDoctorDetails(doctorId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Create Doctor (Admin)
  Future<bool> createDoctor(Map<String, dynamic> doctorData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.createDoctor(doctorData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update Doctor (Admin)
  Future<bool> updateDoctor(String doctorId, Map<String, dynamic> doctorData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateDoctor(doctorId, doctorData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete Doctor (Admin)
  Future<bool> deleteDoctor(String doctorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.deleteDoctor(doctorId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get Doctor Statistics (Admin)
  Future<Map<String, dynamic>> getDoctorStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final stats = await _apiService.getDoctorStats();
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Get Admins (Master only)
  Future<List<dynamic>?> getAdmins() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final admins = await _apiService.getAdmins();
      _isLoading = false;
      notifyListeners();
      return admins;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Create Admin (Master only)
  Future<bool> createAdmin(Map<String, dynamic> adminData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.createAdmin(adminData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update Admin (Master only)
  Future<bool> updateAdmin(String adminId, Map<String, dynamic> adminData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateAdmin(adminId, adminData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete Admin (Master only)
  Future<bool> deleteAdmin(String adminId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.deleteAdmin(adminId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Check if master admin
  bool get isMasterAdmin => _admin?['role'] == 'master';
}
