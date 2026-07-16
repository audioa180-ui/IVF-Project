# Bloom IVF - Patient Consultation App

A comprehensive Flutter mobile application for IVF patients to manage their fertility journey. Built with a patient-centered approach, this app provides appointment booking, doctor discovery, educational resources, personalized guidance, and treatment tracking in a clean, user-friendly interface.

## Features

### 🏠 Home Screen
- Personalized welcome message with user greeting
- Quick appointment booking button
- Search functionality for doctors and clinics
- Upcoming appointment display
- Daily health tips with rotating content
- Treatment journey progress tracker
- Latest IVF blogs and articles
- Emergency contact helpline

### 👨‍⚕️ Doctors Page
- Comprehensive doctor profiles with:
  - Photo, name, qualification, and specialization
  - Experience years and success rates
  - Patient ratings and review counts
  - Languages spoken
  - Real-time availability status
- Doctor detail pages with:
  - About doctor and education background
  - Consultation fees and available time slots
  - Patient reviews and testimonials
- Search by name, specialty, or clinic
- Direct booking from doctor profiles

### 📅 Appointment Management
- Book new appointments with preferred doctors
- Select clinic, date, and time slot
- View upcoming and past appointments
- Cancel appointments with confirmation
- Reschedule existing appointments
- Appointment status tracking (upcoming, completed, cancelled)

### 📚 IVF Knowledge Hub (Blogs)
- Categorized blog articles covering:
  - What is IVF?
  - IVF Success Tips
  - Healthy Diet
  - Pregnancy Care
  - Fertility Myths
  - Men's & Women's Fertility
  - Lifestyle Changes
  - Mental Health
  - Success Stories
- Search and filter by category
- Save favorite articles for later
- Like and share blog posts
- Read time estimates

### 💬 Daily Advice & Tips
- Expert health tips rotating daily
- Categories: Hydration, Diet, Exercise, Mental Health, Medication, Lifestyle
- Practical guidance for IVF treatment
- Easy-to-follow recommendations

### ❤️ Treatment Journey
- Visual timeline tracking IVF progress:
  - First Consultation ✅
  - Blood Tests ✅
  - Ultrasound ✅
  - Egg Retrieval ⏳
  - Embryo Transfer 🔒
  - Pregnancy Test 🔒
  - Follow-up 🔒
- Progress percentage and step-by-step status
- Date tracking for completed steps

### 👤 Profile Management
- Personal information display
- Medical history overview
- Appointment history summary
- Saved blogs collection
- Quick access to all app features
- Settings and logout functionality

### 🔔 Help & Support
- Emergency helpline with one-tap calling
- Live chat support (coming soon)
- Email support integration
- WhatsApp support option
- Comprehensive FAQ section
- Clinic locator (coming soon)

## Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Provider**: State management
- **Material Design 3**: UI components and theming

### Key Dependencies
- `provider`: ^6.1.1 - State management
- `shared_preferences`: ^2.2.2 - Local data persistence
- `intl`: ^0.18.1 - Date and time formatting
- `flutter_svg`: ^2.0.9 - SVG image support
- `cached_network_image`: ^3.3.1 - Image caching
- `url_launcher`: ^6.2.3 - Opening URLs and making calls
- `share_plus`: ^7.2.1 - Content sharing
- `table_calendar`: ^3.0.9 - Calendar widget

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
│   ├── doctor.dart
│   ├── blog.dart
│   ├── appointment.dart
│   └── user.dart
├── data/                    # Mock data
│   └── mock_data.dart
├── providers/               # State management
│   └── app_provider.dart
├── theme/                   # App theming
│   └── app_theme.dart
├── components/              # Reusable UI components
│   ├── doctor_card.dart
│   ├── appointment_card.dart
│   ├── blog_card.dart
│   ├── custom_button.dart
│   ├── search_bar.dart
│   └── app_header.dart
└── screens/                 # Screen implementations
    ├── home/
    │   └── home_screen.dart
    ├── doctors/
    │   ├── doctors_screen.dart
    │   └── doctor_detail_screen.dart
    ├── appointments/
    │   ├── appointments_screen.dart
    │   └── booking_screen.dart
    ├── blogs/
    │   └── blogs_screen.dart
    ├── profile/
    │   └── profile_screen.dart
    ├── treatment/
    │   └── treatment_journey_screen.dart
    ├── advice/
    │   └── advice_screen.dart
    └── help/
        └── help_support_screen.dart
```

## Color Theme

The app uses a calming, medical-friendly color palette:

- **Primary**: Soft Blue (#4A90E2) - Trust and professionalism
- **Secondary**: Mint Green (#8FD3C1) - Health and wellness
- **Accent**: Soft Pink (#F8BBD0) - Compassion and care
- **Background**: White (#FFFFFF) - Clean and modern
- **Cards**: Light Gray (#F5F7FA) - Subtle contrast
- **Success**: Green (#27AE60) - Positive actions
- **Error**: Red (#E74C3C) - Alerts and cancellations
- **Warning**: Orange (#F39C12) - Important notices

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (IDE)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ivf-patient-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### For specific platforms:
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## Usage

### First Launch
1. The app launches with a default user profile
2. Navigate through the bottom navigation bar
3. Explore doctors, blogs, and appointment features

### Booking an Appointment
1. Go to the "Doctors" tab
2. Search or browse available doctors
3. Tap on a doctor to view details
4. Click "Book Appointment"
5. Select clinic, date, and time slot
6. Confirm booking

### Managing Appointments
1. Go to the "Appointments" tab
2. View upcoming and past appointments
3. Cancel or reschedule upcoming appointments
4. Book new appointments directly

### Reading Blogs
1. Navigate to the "Blogs" tab
2. Filter by category or search
3. Tap on articles to read full content
4. Save favorites for later reading
5. Like and share articles

### Tracking Treatment Journey
1. Access from Profile > "Treatment Journey"
2. View progress through IVF steps
3. See completed, in-progress, and locked steps
4. Track dates for completed procedures

## Data Management

### Current State
- Uses mock data for demonstration
- State managed with Provider
- No backend integration yet

### Future Enhancements
- REST API integration
- Real database (MongoDB/PostgreSQL)
- User authentication (JWT)
- Cloud storage for images
- Push notifications (Firebase Cloud Messaging)

## Contributing

This is a demonstration project. For production use, consider:

1. **Backend Integration**: Connect to a real API server
2. **Authentication**: Implement secure user login/registration
3. **Data Validation**: Add form validation and error handling
4. **Testing**: Write unit and integration tests
5. **Performance**: Optimize images and API calls
6. **Accessibility**: Improve screen reader support
7. **Localization**: Add multi-language support

## License

This project is created for educational purposes.

## Acknowledgments

- Medical content is for demonstration purposes
- Doctor profiles and reviews are fictional
- Always consult real healthcare professionals for medical advice

## Support

For questions or issues, please refer to the in-app Help & Support section or contact the development team.

---

**Note**: This app is a demonstration/prototype. For actual medical use, ensure proper HIPAA compliance, data security, and consultation with healthcare professionals.
