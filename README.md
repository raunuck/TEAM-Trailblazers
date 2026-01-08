# 🐝 PlanBEE

**Adaptive Student Time Utilisation & Learning Continuity App**

Transform wasted academic downtime into productive learning opportunities. PlanBEE intelligently adapts to your schedule changes and helps you make the most of every free moment.

---

## 🎯 Overview

PlanBEE is a smart mobile application designed for college and university students to optimize their time when classes get cancelled or schedules change unexpectedly. Instead of letting free time go to waste, PlanBEE instantly suggests productive activities tailored to the duration and context of your newfound availability.

### Key Features

- 📅 **Smart Calendar Integration** - Seamlessly sync with Google Calendar
- ⚡ **Real-Time Schedule Adaptation** - Instant updates when classes are cancelled
- 🎓 **Intelligent Recommendations** - Context-aware activity suggestions based on available time
- 💡 **Personal Vault** - Store and manage long-term ideas and projects
- 👥 **Community Learning** - Connect with peers during shared free time
- 🔔 **Smart Notifications** - Stay informed about schedule changes and opportunities

---

## 🚀 Tech Stack

### Frontend
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider / Riverpod

### Backend
- **Platform**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth
- **Real-time Updates**: Supabase Realtime
- **APIs**: Supabase Edge Functions

### Integrations
- **Calendar**: Google Calendar API

---

## 📱 Core Functionality

### 1. Schedule Management
- Import events from Google Calendar
- Automatic categorization (Classes, Breaks, Other)
- Mark classes as cancelled or rescheduled
- Real-time free slot detection

### 2. Opportunity Recommendations
Based on available time duration:
- **Short gaps (< 30 min)**: Quick reading, revision notes
- **Medium gaps (30 min - 2 hrs)**: Learning modules, focused tasks
- **Long gaps (2+ hrs)**: Deep work, group activities, vault projects

### 3. Learning Modules
- Curated external educational content
- Categorized by duration and domain
- Quick-launch from app interface

### 4. Community Learning
- Propose group activities during shared free time
- Real-time join/leave functionality
- Visibility of participant lists
- Works only for overlapping schedules

### 5. Vault System
- Personal repository for ideas and projects
- Categorized entries with priority levels
- Suggestions during long free periods

---

## 🏗️ Architecture

### Database Schema

```sql
-- Profiles (extends auth.users)
profiles
├── id (uuid, FK to auth.users)
├── full_name (text)
├── email (text)
├── role (text: 'Student' | 'Teacher')
├── interests (text[])
└── created_at (timestamptz)

-- Calendar Events
calendar_events
├── id (uuid)
├── user_id (uuid, FK to auth.users)
├── title (text)
├── start_time (timestamp)
├── end_time (timestamp)
├── source (text)
└── created_at (timestamp)

-- Tasks
tasks
├── id (uuid)
├── user_id (uuid, FK to auth.users)
├── title (text)
├── priority (text)
├── estimated_minutes (integer)
├── is_completed (boolean)
└── created_at (timestamp)

-- Free Slots (auto-detected gaps)
free_slots
├── id (uuid)
├── user_id (uuid, FK to auth.users)
├── start_time (timestamp)
├── end_time (timestamp)
├── source_event_id (uuid)
└── created_at (timestamp)

-- Ideas (Vault System)
ideas
├── id (bigint, auto-increment)
├── user_id (uuid, FK to auth.users)
├── title (text)
├── description (text)
├── status (text, default: 'Not Started')
└── created_at (timestamptz)

-- Community Events
community_events
├── id (uuid)
├── creator_id (uuid, FK to auth.users)
├── title (text)
├── description (text)
├── location (text)
├── event_time (timestamptz)
├── participants (uuid[])
├── tags (text[])
└── created_at (timestamptz)
```

---

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / Xcode
- Supabase Account
- Google Cloud Console Account (for Calendar API)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/planbee.git
cd planbee
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Supabase**
- Create a new project at [supabase.com](https://supabase.com)
- Copy your project URL and anon key
- Create a `.env` file in the root directory:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

4. **Set up Google Calendar API**
- Enable Google Calendar API in Google Cloud Console
- Create OAuth 2.0 credentials
- Add credentials to your project

5. **Run the app**
```bash
flutter run
```

---

## 📋 MVP Scope 

### Implemented Features
✅ User authentication (Supabase Auth)  
✅ Google Calendar integration  
✅ Schedule display and management  
✅ Class cancellation functionality  
✅ Free time slot detection  
✅ Rule-based recommendations  
✅ Basic vault system  
✅ Task completion tracking  

### Limited in MVP
⚠️ Community learning (basic version)  
⚠️ Curated learning modules (limited links)  
⚠️ Notifications (local only)  

### Future Enhancements
🔮 AI-powered personalized recommendations  
🔮 LMS integration  
🔮 Productivity analytics and insights  
🔮 Gamification and achievement system  
🔮 Mentor-led learning sessions  
🔮 Multi-calendar support  

---

## 🎨 UI/UX Highlights

- **Clean, Student-Friendly Interface** - Intuitive navigation with minimal taps
- **Real-Time Updates** - Instant reflection of schedule changes
- **Offline Support** - Read access to cached data
- **Responsive Design** - Optimized for various screen sizes

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👥 Team

**Developers**: Raunak, Viral, Avni & Sarthak  

**Institution**: IET-DAVV,Indore

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact

For questions or feedback, reach out to:
- Email: raunak.eleven@gmail.com
- GitHub: [@raunuck](https://github.com/raunuck)

---

## 🙏 Acknowledgments

- Supabase for the excellent backend platform
- Flutter community for amazing packages and support
- Google Calendar API for seamless integration
- All contributors and testers

---

**Made with ☕ and 💻 for Hackvento**

> "Because every minute matters when you're a student." 🐝
