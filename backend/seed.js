require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://audioa180_db_user:9ToNBulgSMJwrs9U@cluster0.vc3reag.mongodb.net/bloom_ivf?retryWrites=true&w=majority';

const doctorData = [
  { name: 'Dr. Priya Sharma', photo: '👩‍⚕️', qualification: 'MD, DGO, Fellowship in Reproductive Medicine', experience: 15, specialization: 'IVF & Reproductive Endocrinology', rating: 4.9, reviewCount: 234, languages: ['English', 'Hindi', 'Marathi'], availableToday: true, clinic: 'Bloom IVF Center - Mumbai', about: 'Dr. Priya Sharma is a renowned fertility specialist with over 15 years of experience in IVF treatments.', education: ['MBBS - AIIMS Delhi', 'MD Obstetrics & Gynecology - KEM Mumbai', 'Fellowship in Reproductive Medicine - UK'], successRate: 72, consultationFee: 1500, availableSlots: ['09:00 AM', '10:30 AM', '02:00 PM', '04:30 PM'],
    reviews: [
      { patientName: 'Anita Desai', rating: 5, comment: 'Dr. Priya is incredibly compassionate and knowledgeable. She made us feel at ease throughout our IVF journey.', date: '2026-06-15' },
      { patientName: 'Meera K.', rating: 5, comment: 'Best fertility doctor in Mumbai! Our first cycle was successful thanks to her expertise.', date: '2026-05-20' },
      { patientName: 'Neha S.', rating: 4, comment: 'Very thorough with her explanations. The success rate speaks for itself.', date: '2026-04-10' },
    ] },
  { name: 'Dr. Rajesh Kumar', photo: '👨‍⚕️', qualification: 'MS, MCh, DNB in Reproductive Surgery', experience: 12, specialization: 'Male Infertility & Andrology', rating: 4.8, reviewCount: 189, languages: ['English', 'Hindi'], availableToday: true, clinic: 'HopeNest Clinic - Delhi', about: 'Dr. Rajesh Kumar specializes in male fertility issues and advanced reproductive surgeries.', education: ['MBBS - Maulana Azad Medical College', 'MS General Surgery - AIIMS', 'MCh Urology - PGI Chandigarh'], successRate: 68, consultationFee: 1200, availableSlots: ['11:00 AM', '01:00 PM', '03:30 PM', '05:00 PM'],
    reviews: [
      { patientName: 'Amit R.', rating: 5, comment: 'Dr. Rajesh diagnosed and treated a male factor issue that other doctors missed.', date: '2026-06-01' },
      { patientName: 'Sneha P.', rating: 4, comment: 'Very professional and empathetic approach. Highly recommended.', date: '2026-05-12' },
    ] },
  { name: 'Dr. Ananya Patel', photo: '👩‍⚕️', qualification: 'MD, DNB, Certificate in ART', experience: 10, specialization: 'Embryology & IVF Lab Director', rating: 4.7, reviewCount: 156, languages: ['English', 'Hindi', 'Gujarati'], availableToday: false, clinic: 'FertiCare Hospital - Bangalore', about: 'Dr. Ananya Patel leads the embryology lab at FertiCare with expertise in advanced IVF techniques.', education: ['MBBS - BJ Medical College', 'MD Obstetrics & Gynecology - NIMHANS', 'Certificate in ART - ESHRE'], successRate: 75, consultationFee: 1800, availableSlots: ['10:00 AM', '12:00 PM', '02:30 PM'],
    reviews: [
      { patientName: 'Priyanka G.', rating: 5, comment: 'Dr. Ananya\'s lab expertise gave us a successful outcome after multiple failed cycles elsewhere.', date: '2026-06-22' },
      { patientName: 'Divya M.', rating: 5, comment: 'She is extremely dedicated and stays updated with the latest ART techniques.', date: '2026-05-30' },
      { patientName: 'Ritu S.', rating: 4, comment: 'Very caring doctor. The lab team is world-class.', date: '2026-04-18' },
    ] },
  { name: 'Dr. Vikram Singh', photo: '👨‍⚕️', qualification: 'MD, Fellowship in Fertility Preservation', experience: 8, specialization: 'Fertility Preservation & Oncology', rating: 4.6, reviewCount: 98, languages: ['English', 'Hindi', 'Punjabi'], availableToday: true, clinic: 'Miracle IVF - Pune', about: 'Dr. Vikram Singh specializes in fertility preservation for cancer patients.', education: ['MBBS - AFMC Pune', 'MD Obstetrics & Gynecology - SGPGI Lucknow', 'Fellowship - Cleveland Clinic USA'], successRate: 70, consultationFee: 1400, availableSlots: ['09:30 AM', '11:30 AM', '04:00 PM'],
    reviews: [
      { patientName: 'Kavita D.', rating: 5, comment: 'Dr. Vikram helped me preserve my fertility before cancer treatment. Forever grateful!', date: '2026-06-10' },
    ] },
];

const blogData = [
  { title: 'Understanding IVF: A Complete Guide for Beginners', excerpt: 'Learn what IVF is, how it works, and what to expect.', content: 'In vitro fertilization (IVF) is a process where an egg and sperm are combined outside the body in a laboratory.\n\nThe IVF process typically involves:\n1. Ovarian stimulation\n2. Egg retrieval\n3. Fertilization in the lab\n4. Embryo culture\n5. Embryo transfer\n6. Pregnancy test\n\nIVF has helped millions of couples worldwide achieve pregnancy.', category: 'What is IVF?', readTime: 8, likes: 342, image: '🧬', author: 'Dr. Priya Sharma', date: new Date('2026-07-10') },
  { title: '10 Proven Tips to Improve Your IVF Success Rate', excerpt: 'Evidence-based strategies to maximize your chances.', content: '1. Maintain a healthy BMI\n2. Quit smoking\n3. Take prescribed supplements\n4. Manage stress\n5. Follow medication schedule\n6. Get adequate sleep\n7. Stay hydrated\n8. Avoid excessive caffeine\n9. Communicate with your doctor\n10. Stay positive', category: 'IVF Success Tips', readTime: 6, likes: 567, image: '💡', author: 'Dr. Ananya Patel', date: new Date('2026-07-08') },
  { title: 'Fertility-Boosting Foods for Your IVF Journey', excerpt: 'Nutrition plays a key role in fertility.', content: 'Best foods to include:\n- Leafy greens for folate\n- Berries for antioxidants\n- Nuts and seeds for omega-3\n- Whole grains for fiber\n- Lean proteins\n- Avocados for healthy fats\n\nFoods to limit:\n- Processed foods\n- Trans fats\n- Excessive sugar', category: 'Healthy Diet', readTime: 5, likes: 289, image: '🥗', author: 'Nutrition Team', date: new Date('2026-07-05') },
  { title: 'Managing Stress During IVF Treatment', excerpt: 'Mental health is crucial during fertility treatment.', content: 'IVF can be emotionally challenging. Here are proven stress management techniques:\n- Deep breathing exercises\n- Support groups\n- Counseling or therapy\n- Journaling\n- Stay connected with loved ones\n- Set realistic expectations\n- Take breaks between cycles\n- Focus on self-care', category: 'Mental Health', readTime: 7, likes: 445, image: '🧘', author: 'Dr. Priya Sharma', date: new Date('2026-07-03') },
  { title: 'Our Success Story: From Heartbreak to Happiness', excerpt: 'Read how Priya and Rahul found hope after 3 years of trying.', content: 'After three years of trying to conceive naturally, we decided to explore IVF. The first cycle was unsuccessful, and we were devastated.\n\nWith some lifestyle changes and a modified protocol, our second cycle was successful!\n\nToday, we are proud parents of a beautiful baby girl.', category: 'Success Stories', readTime: 4, likes: 892, image: '👶', author: 'Priya & Rahul M.', date: new Date('2026-06-28') },
  { title: '5 Common Fertility Myths Debunked', excerpt: 'Separate fact from fiction with science-backed answers.', content: 'Myth 1: IVF guarantees pregnancy\nMyth 2: Only women have fertility issues\nMyth 3: Age doesn\'t matter for IVF\nMyth 4: Bed rest after embryo transfer helps\nMyth 5: IVF babies are less healthy', category: 'Fertility Myths', readTime: 5, likes: 378, image: '🔍', author: 'Medical Team', date: new Date('2026-06-25') },
];

async function seed() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB');

  const Doctor = require('./models/Doctor');
  const Blog = require('./models/Blog');
  const User = require('./models/User');

  await Doctor.deleteMany({});
  await Blog.deleteMany({});
  await User.deleteMany({});

  const doctors = await Doctor.insertMany(doctorData);
  console.log(`Seeded ${doctors.length} doctors`);

  const blogs = await Blog.insertMany(blogData);
  console.log(`Seeded ${blogs.length} blogs`);

  const demoUser = await User.create({
    name: 'Anita Desai',
    email: 'anita@bloomivf.com',
    password: 'test1234',
    age: 32,
    gender: 'Female',
    bloodGroup: 'B+',
    phone: '+91 98765 43210',
    medicalHistory: 'PCOS diagnosed 2023. No major surgeries.',
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
    likedBlogs: [blogs[1]._id.toString(), blogs[4]._id.toString()],
    savedBlogs: [blogs[0]._id.toString(), blogs[2]._id.toString()],
  });
  console.log(`Seeded demo user: ${demoUser.email} / test1234`);

  console.log('\nSeed complete!');
  process.exit(0);
}

seed().catch(err => {
  console.error('Seed error:', err);
  process.exit(1);
});
