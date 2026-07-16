import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ivf_patient_app/data/mock_data.dart';
import 'package:ivf_patient_app/models/appointment.dart';
import 'package:ivf_patient_app/models/user.dart';
import 'package:ivf_patient_app/services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  static const _tokenKey = 'auth_token';

  User _user = MockData.defaultUser;
  bool _isLoggedIn = false;
  List<Appointment> _appointments = [];
  Set<String> _savedBlogs = {};
  Set<String> _likedBlogs = {};
  String _searchQuery = '';
  bool _loading = false;
  String? _error;

  User get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  Set<String> get savedBlogs => Set.unmodifiable(_savedBlogs);
  Set<String> get likedBlogs => Set.unmodifiable(_likedBlogs);
  String get searchQuery => _searchQuery;
  bool get loading => _loading;
  String? get error => _error;
  List<Appointment> get upcomingAppointments => _appointments
      .where((a) => a.status == AppointmentStatus.upcoming)
      .toList();
  List<Appointment> get completedAppointments => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .toList();
  List<Appointment> get cancelledAppointments => _appointments
      .where((a) => a.status == AppointmentStatus.cancelled)
      .toList();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null && token.isNotEmpty) {
      api.setToken(token);
      try {
        _user = await api.getMe();
        _isLoggedIn = true;
        _appointments = await api.getAppointments();
        final prefsData = await api.getBlogPreferences();
        _savedBlogs = Set<String>.from(prefsData['savedBlogs'] ?? []);
        _likedBlogs = Set<String>.from(prefsData['likedBlogs'] ?? []);
      } catch (_) {
        api.setToken(null);
        await prefs.remove(_tokenKey);
      }
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await api.login(email, password);
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, api.token ?? '');
      _appointments = await api.getAppointments();
      final prefsData = await api.getBlogPreferences();
      _savedBlogs = Set<String>.from(prefsData['savedBlogs'] ?? []);
      _likedBlogs = Set<String>.from(prefsData['likedBlogs'] ?? []);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await api.register(name, email, password);
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, api.token ?? '');
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> completeProfile(User value) async {
    try {
      _user = await api.updateProfile(value.toJson());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _user = MockData.defaultUser;
    _appointments = [];
    _savedBlogs = {};
    _likedBlogs = {};
    api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String clinic,
    required DateTime date,
    required String time,
  }) async {
    try {
      final apt = await api.bookAppointment(
        doctorId: doctorId,
        doctorName: doctorName,
        clinic: clinic,
        date: date,
        time: time,
      );
      _appointments.insert(0, apt);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await api.cancelAppointment(appointmentId);
      _appointments = _appointments.map((a) => a.id == appointmentId
          ? Appointment(
              id: a.id,
              doctorId: a.doctorId,
              doctorName: a.doctorName,
              clinic: a.clinic,
              date: a.date,
              time: a.time,
              status: AppointmentStatus.cancelled)
          : a).toList();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      await api.rescheduleAppointment(appointmentId, newDate, newTime);
      _appointments = _appointments.map((a) => a.id == appointmentId
          ? Appointment(
              id: a.id,
              doctorId: a.doctorId,
              doctorName: a.doctorName,
              clinic: a.clinic,
              date: newDate,
              time: newTime,
              status: AppointmentStatus.upcoming)
          : a).toList();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> toggleSaveBlog(String blogId) async {
    try {
      await api.toggleSaveBlog(blogId);
      _savedBlogs.contains(blogId)
          ? _savedBlogs.remove(blogId)
          : _savedBlogs.add(blogId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> toggleLikeBlog(String blogId) async {
    try {
      await api.toggleLikeBlog(blogId);
      _likedBlogs.contains(blogId)
          ? _likedBlogs.remove(blogId)
          : _likedBlogs.add(blogId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
