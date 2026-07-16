import 'package:flutter/material.dart';
import 'package:ivf_patient_app/models/doctor.dart';
import 'package:ivf_patient_app/models/blog.dart';
import 'package:ivf_patient_app/models/appointment.dart';
import 'package:ivf_patient_app/models/user.dart';

class MockData {
  static const String primaryClinic = 'Bloom IVF Center - Mumbai';

  static List<Doctor> get doctors => [
        Doctor(
          id: '1',
          name: 'Dr. Priya Sharma',
          photo: '👩‍⚕️',
          qualification: 'MD, DGO, Fellowship in Reproductive Medicine',
          experience: 15,
          specialization: 'IVF & Reproductive Endocrinology',
          rating: 4.9,
          reviewCount: 234,
          languages: ['English', 'Hindi', 'Marathi'],
          availableToday: true,
          clinic: 'Bloom IVF Center - Mumbai',
          about:
              'Dr. Priya Sharma is a renowned fertility specialist with over 15 years of experience in IVF treatments. She has helped thousands of couples achieve their dream of parenthood.',
          education: [
            'MBBS - AIIMS Delhi',
            'MD Obstetrics & Gynecology - KEM Mumbai',
            'Fellowship in Reproductive Medicine - UK'
          ],
          successRate: 72,
          consultationFee: 1500,
          availableSlots: ['09:00 AM', '10:30 AM', '02:00 PM', '04:30 PM'],
        ),
        Doctor(
          id: '2',
          name: 'Dr. Rajesh Kumar',
          photo: '👨‍⚕️',
          qualification: 'MS, MCh, DNB in Reproductive Surgery',
          experience: 12,
          specialization: 'Male Infertility & Andrology',
          rating: 4.8,
          reviewCount: 189,
          languages: ['English', 'Hindi'],
          availableToday: true,
          clinic: 'HopeNest Clinic - Delhi',
          about:
              'Dr. Rajesh Kumar specializes in male fertility issues and advanced reproductive surgeries. His patient-first approach has earned him recognition nationwide.',
          education: [
            'MBBS - Maulana Azad Medical College',
            'MS General Surgery - AIIMS',
            'MCh Urology - PGI Chandigarh'
          ],
          successRate: 68,
          consultationFee: 1200,
          availableSlots: ['11:00 AM', '01:00 PM', '03:30 PM', '05:00 PM'],
        ),
        Doctor(
          id: '3',
          name: 'Dr. Ananya Patel',
          photo: '👩‍⚕️',
          qualification: 'MD, DNB, Certificate in ART',
          experience: 10,
          specialization: 'Embryology & IVF Lab Director',
          rating: 4.7,
          reviewCount: 156,
          languages: ['English', 'Hindi', 'Gujarati'],
          availableToday: false,
          clinic: 'FertiCare Hospital - Bangalore',
          about:
              'Dr. Ananya Patel leads the embryology lab at FertiCare with expertise in advanced IVF techniques including ICSI and PGT.',
          education: [
            'MBBS - BJ Medical College',
            'MD Obstetrics & Gynecology - NIMHANS',
            'Certificate in ART - ESHRE'
          ],
          successRate: 75,
          consultationFee: 1800,
          availableSlots: ['10:00 AM', '12:00 PM', '02:30 PM'],
        ),
        Doctor(
          id: '4',
          name: 'Dr. Vikram Singh',
          photo: '👨‍⚕️',
          qualification: 'MD, Fellowship in Fertility Preservation',
          experience: 8,
          specialization: 'Fertility Preservation & Oncology',
          rating: 4.6,
          reviewCount: 98,
          languages: ['English', 'Hindi', 'Punjabi'],
          availableToday: true,
          clinic: 'Miracle IVF - Pune',
          about:
              'Dr. Vikram Singh specializes in fertility preservation for cancer patients and couples seeking delayed parenthood options.',
          education: [
            'MBBS - AFMC Pune',
            'MD Obstetrics & Gynecology - SGPGI Lucknow',
            'Fellowship - Cleveland Clinic USA'
          ],
          successRate: 70,
          consultationFee: 1400,
          availableSlots: ['09:30 AM', '11:30 AM', '04:00 PM'],
        ),
      ];

  static List<String> get blogCategories => [
        'What is IVF?',
        'IVF Success Tips',
        'Healthy Diet',
        'Pregnancy Care',
        'Fertility Myths',
        "Men's Fertility",
        "Women's Fertility",
        'Lifestyle Changes',
        'Mental Health',
        'Success Stories',
      ];

  static List<Blog> get blogs => [
        Blog(
          id: '1',
          title: 'Understanding IVF: A Complete Guide for Beginners',
          excerpt:
              'Learn what IVF is, how it works, and what to expect during your fertility journey.',
          content:
              'In vitro fertilization (IVF) is a process where an egg and sperm are combined outside the body in a laboratory. The resulting embryo is then transferred to the uterus.\n\nThe IVF process typically involves:\n1. Ovarian stimulation with medications\n2. Egg retrieval procedure\n3. Fertilization in the lab\n4. Embryo culture and monitoring\n5. Embryo transfer\n6. Pregnancy test after 2 weeks\n\nIVF has helped millions of couples worldwide achieve pregnancy. Success rates vary based on age, health factors, and clinic expertise.',
          category: 'What is IVF?',
          readTime: 8,
          likes: 342,
          image: '🧬',
          author: 'Dr. Priya Sharma',
          date: DateTime(2026, 7, 10),
        ),
        Blog(
          id: '2',
          title: '10 Proven Tips to Improve Your IVF Success Rate',
          excerpt:
              'Evidence-based strategies to maximize your chances of a successful IVF cycle.',
          content:
              'Improving your IVF success rate involves both medical and lifestyle factors:\n\n1. Maintain a healthy BMI (18.5-24.9)\n2. Quit smoking and limit alcohol\n3. Take prescribed supplements (folic acid, vitamin D)\n4. Manage stress through meditation or yoga\n5. Follow medication schedule strictly\n6. Get adequate sleep (7-8 hours)\n7. Stay hydrated\n8. Avoid excessive caffeine\n9. Communicate openly with your doctor\n10. Stay positive and patient',
          category: 'IVF Success Tips',
          readTime: 6,
          likes: 567,
          image: '💡',
          author: 'Dr. Ananya Patel',
          date: DateTime(2026, 7, 8),
        ),
        Blog(
          id: '3',
          title: 'Fertility-Boosting Foods for Your IVF Journey',
          excerpt:
              'Nutrition plays a key role in fertility. Discover the best foods to include in your diet.',
          content:
              'A balanced diet rich in antioxidants, healthy fats, and essential nutrients can support your fertility:\n\nBest foods to include:\n- Leafy greens (spinach, kale) for folate\n- Berries for antioxidants\n- Nuts and seeds for omega-3\n- Whole grains for fiber\n- Lean proteins (fish, chicken, legumes)\n- Avocados for healthy fats\n\nFoods to limit:\n- Processed foods\n- Trans fats\n- Excessive sugar\n- High-mercury fish',
          category: 'Healthy Diet',
          readTime: 5,
          likes: 289,
          image: '🥗',
          author: 'Nutrition Team',
          date: DateTime(2026, 7, 5),
        ),
        Blog(
          id: '4',
          title: 'Managing Stress During IVF Treatment',
          excerpt:
              'Mental health is crucial during fertility treatment. Learn coping strategies that work.',
          content:
              'IVF can be emotionally challenging. Here are proven stress management techniques:\n\n- Practice deep breathing exercises daily\n- Join a support group for IVF patients\n- Consider counseling or therapy\n- Maintain a journal of your journey\n- Stay connected with loved ones\n- Set realistic expectations\n- Take breaks between cycles if needed\n- Focus on self-care activities you enjoy\n\nRemember: seeking help is a sign of strength, not weakness.',
          category: 'Mental Health',
          readTime: 7,
          likes: 445,
          image: '🧘',
          author: 'Dr. Priya Sharma',
          date: DateTime(2026, 7, 3),
        ),
        Blog(
          id: '5',
          title: 'Our Success Story: From Heartbreak to Happiness',
          excerpt:
              'Read how Priya and Rahul found hope after 3 years of trying and 2 IVF cycles.',
          content:
              'After three years of trying to conceive naturally, we decided to explore IVF. The first cycle was unsuccessful, and we were devastated.\n\nOur doctor encouraged us not to lose hope. With some lifestyle changes and a modified protocol, our second cycle was successful!\n\nToday, we are proud parents of a beautiful baby girl. To anyone reading this — don\'t give up. Every journey is unique, and hope is always there.',
          category: 'Success Stories',
          readTime: 4,
          likes: 892,
          image: '👶',
          author: 'Priya & Rahul M.',
          date: DateTime(2026, 6, 28),
        ),
        Blog(
          id: '6',
          title: '5 Common Fertility Myths Debunked',
          excerpt:
              'Separate fact from fiction with science-backed answers to common fertility questions.',
          content:
              'Myth 1: IVF guarantees pregnancy\nFact: Success rates vary; no treatment guarantees pregnancy.\n\nMyth 2: Only women have fertility issues\nFact: Male factor contributes to ~40% of infertility cases.\n\nMyth 3: Age doesn\'t matter for IVF\nFact: Egg quality declines significantly after 35.\n\nMyth 4: Bed rest after embryo transfer helps\nFact: Normal activity is fine; excessive rest isn\'t needed.\n\nMyth 5: IVF babies are less healthy\nFact: IVF children are as healthy as naturally conceived children.',
          category: 'Fertility Myths',
          readTime: 5,
          likes: 378,
          image: '🔍',
          author: 'Medical Team',
          date: DateTime(2026, 6, 25),
        ),
      ];

  static List<DailyTip> get dailyTips => [
        DailyTip(
          id: '1',
          title: 'Stay Hydrated',
          description:
              'Drink at least 8 glasses of water daily to support overall health and egg quality.',
          icon: '💧',
          category: 'Hydration',
        ),
        DailyTip(
          id: '2',
          title: 'Balanced Nutrition',
          description:
              'Include leafy greens, whole grains, and lean proteins in every meal.',
          icon: '🥗',
          category: 'Diet',
        ),
        DailyTip(
          id: '3',
          title: 'Gentle Exercise',
          description:
              '30 minutes of walking or yoga helps reduce stress and improves blood circulation.',
          icon: '🏃',
          category: 'Exercise',
        ),
        DailyTip(
          id: '4',
          title: 'Stress Relief',
          description:
              'Practice 10 minutes of deep breathing or meditation before bedtime.',
          icon: '🧘',
          category: 'Mental Health',
        ),
        DailyTip(
          id: '5',
          title: 'Medicine Reminder',
          description:
              'Take your prescribed medications at the same time each day for best results.',
          icon: '💊',
          category: 'Medication',
        ),
        DailyTip(
          id: '6',
          title: 'Quality Sleep',
          description:
              'Aim for 7-8 hours of uninterrupted sleep to support hormone balance.',
          icon: '😴',
          category: 'Lifestyle',
        ),
        DailyTip(
          id: '7',
          title: 'Limit Caffeine',
          description:
              'Keep caffeine intake under 200mg per day during treatment.',
          icon: '☕',
          category: 'Lifestyle',
        ),
      ];

  static List<TreatmentStep> get treatmentSteps => [
        TreatmentStep(
          id: '1',
          title: 'First Consultation',
          description: 'Initial assessment and treatment plan',
          status: TreatmentStatus.completed,
          date: '2026-05-15',
        ),
        TreatmentStep(
          id: '2',
          title: 'Blood Tests',
          description: 'Hormone levels and health screening',
          status: TreatmentStatus.completed,
          date: '2026-05-20',
        ),
        TreatmentStep(
          id: '3',
          title: 'Ultrasound',
          description: 'Ovarian and uterine evaluation',
          status: TreatmentStatus.completed,
          date: '2026-05-25',
        ),
        TreatmentStep(
          id: '4',
          title: 'Egg Retrieval',
          description: 'Procedure to collect eggs',
          status: TreatmentStatus.inProgress,
          date: '2026-07-20',
        ),
        TreatmentStep(
          id: '5',
          title: 'Embryo Transfer',
          description: 'Transfer of embryo to uterus',
          status: TreatmentStatus.locked,
        ),
        TreatmentStep(
          id: '6',
          title: 'Pregnancy Test',
          description: 'Blood test to confirm pregnancy',
          status: TreatmentStatus.locked,
        ),
        TreatmentStep(
          id: '7',
          title: 'Follow-up',
          description: 'Post-transfer monitoring and care',
          status: TreatmentStatus.locked,
        ),
      ];

  static List<Review> get reviews => [
        Review(
          id: '1',
          doctorId: '1',
          patientName: 'Sneha R.',
          rating: 5,
          comment:
              'Dr. Priya is incredibly compassionate and knowledgeable. She explained every step clearly.',
          date: '2026-06-15',
        ),
        Review(
          id: '2',
          doctorId: '1',
          patientName: 'Meera K.',
          rating: 5,
          comment:
              'After 2 failed cycles elsewhere, Dr. Priya helped us succeed on our first try with her!',
          date: '2026-05-28',
        ),
        Review(
          id: '3',
          doctorId: '2',
          patientName: 'Arjun P.',
          rating: 4,
          comment:
              'Very professional and thorough. Dr. Rajesh addressed all our concerns about male factor infertility.',
          date: '2026-06-10',
        ),
      ];

  static List<String> get clinics => [
        primaryClinic,
      ];

  static List<FAQ> get faqs => [
        FAQ(
          question: 'How do I book an appointment?',
          answer:
              'Go to the Doctors tab, select a doctor, and tap "Book Appointment". Choose your preferred clinic, date, and time slot to confirm.',
        ),
        FAQ(
          question: 'Can I reschedule my appointment?',
          answer:
              'Yes. Open the Appointments tab, find your upcoming visit, and tap "Reschedule" to pick a new date and time.',
        ),
        FAQ(
          question: 'What should I bring to my first consultation?',
          answer:
              'Bring your ID, previous medical records, list of current medications, and any prior fertility test results.',
        ),
        FAQ(
          question: 'How long does an IVF cycle take?',
          answer:
              'A typical IVF cycle takes about 4-6 weeks from ovarian stimulation to embryo transfer, followed by a pregnancy test after 2 weeks.',
        ),
        FAQ(
          question: 'Is my medical information secure?',
          answer:
              'Yes. Your data is stored securely and is only accessible to authorized medical staff involved in your care.',
        ),
      ];

  static List<String> get timeSlots => [
        '09:00 AM',
        '09:30 AM',
        '10:00 AM',
        '10:30 AM',
        '11:00 AM',
        '11:30 AM',
        '02:00 PM',
        '02:30 PM',
        '03:00 PM',
        '03:30 PM',
        '04:00 PM',
        '04:30 PM',
        '05:00 PM',
      ];

  static User get defaultUser => User(
        name: 'Anita Desai',
        age: 32,
        gender: 'Female',
        bloodGroup: 'B+',
        phone: '+91 98765 43210',
        email: 'anita.desai@email.com',
        medicalHistory: 'PCOS diagnosed 2023. No major surgeries.',
        photo: '👩',
        partnerName: 'Rahul Desai',
        tryingSince: '2 years',
        previousIvfAttempts: 0,
        menstrualCycleDays: 32,
        height: '162 cm',
        weight: '58 kg',
        allergies: 'None',
        currentMedications: 'Metformin 500mg',
        maritalStatus: 'Married',
        profileComplete: true,
      );

  static List<HomeTool> get careTools => [
        HomeTool(
          icon: Icons.medication_outlined,
          title: 'Medication Tracker',
          subtitle: 'Track fertility meds & injections',
          color: 0xFFF8BBD9,
        ),
        HomeTool(
          icon: Icons.calendar_month_outlined,
          title: 'Cycle Calendar',
          subtitle: 'Log periods & ovulation days',
          color: 0xFFE1BEE7,
        ),
        HomeTool(
          icon: Icons.favorite_outline,
          title: 'Symptoms Diary',
          subtitle: 'Record daily symptoms & mood',
          color: 0xFFFFCCBC,
        ),
        HomeTool(
          icon: Icons.calculate_outlined,
          title: 'BMI Calculator',
          subtitle: 'Monitor healthy weight range',
          color: 0xFFC8E6C9,
        ),
        HomeTool(
          icon: Icons.water_drop_outlined,
          title: 'Hydration Log',
          subtitle: 'Stay hydrated during treatment',
          color: 0xFFB3E5FC,
        ),
        HomeTool(
          icon: Icons.self_improvement_outlined,
          title: 'Mindfulness',
          subtitle: 'Guided relaxation & breathing',
          color: 0xFFD1C4E9,
        ),
      ];

  static List<QuickAction> get quickActions => [
        QuickAction(
          icon: Icons.calendar_today,
          label: 'Book Visit',
          color: 0xFFE91E63,
        ),
        QuickAction(
          icon: Icons.local_hospital_outlined,
          label: 'Find Doctor',
          color: 0xFF9C27B0,
        ),
        QuickAction(
          icon: Icons.timeline,
          label: 'My Journey',
          color: 0xFFFF7043,
        ),
        QuickAction(
          icon: Icons.lightbulb_outline,
          label: 'Daily Tips',
          color: 0xFFEC407A,
        ),
      ];

  static List<Appointment> get defaultAppointments => [
        Appointment(
          id: '1',
          doctorId: '1',
          doctorName: 'Dr. Priya Sharma',
          clinic: 'Bloom IVF Center - Mumbai',
          date: DateTime(2026, 7, 20),
          time: '10:30 AM',
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: '2',
          doctorId: '2',
          doctorName: 'Dr. Rajesh Kumar',
          clinic: 'HopeNest Clinic - Delhi',
          date: DateTime(2026, 6, 15),
          time: '02:00 PM',
          status: AppointmentStatus.completed,
        ),
      ];
}

class HomeTool {
  final IconData icon;
  final String title;
  final String subtitle;
  final int color;

  HomeTool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class QuickAction {
  final IconData icon;
  final String label;
  final int color;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class DailyTip {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;

  DailyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });
}

class TreatmentStep {
  final String id;
  final String title;
  final String description;
  final TreatmentStatus status;
  final String? date;

  TreatmentStep({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.date,
  });
}

enum TreatmentStatus {
  completed,
  inProgress,
  locked,
}

class Review {
  final String id;
  final String doctorId;
  final String patientName;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}
