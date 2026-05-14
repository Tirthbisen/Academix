# Academix 🎓
**Smart Attendance Tracker & Bunk Manager — Personal Prototype**

> ⚠️ **This is a self-built prototype**, developed independently as a personal learning project during Semester 1 of my B.Tech CSE. It is not a commercial product. I built this to solve a real problem I face daily as a college student and to learn Flutter, Firebase, and mobile app architecture hands-on.

⬇️ **[Download APK (v1.0.1-beta)](https://github.com/Tirthbisen/Academix/releases/tag/academix)**
> Android will show a Play Protect warning on install — this is normal for all sideloaded APKs. Tap "Install anyway" to proceed.

---

## 💡 What Problem Does It Solve?

Every college student in India needs to maintain 75% attendance or face consequences. Tracking this manually across 8-10 subjects with different lecture/tutorial/practical weightages is painful. Academix does it automatically and tells you exactly how many classes you can safely skip — or how many you must attend to recover.

---

## 📱 Screenshots

| Login | Dashboard | Subjects |
|---|---|---|
| Google Auth + Email | Calendar + daily classes | Per-subject % with danger zone |

> *Screenshots available in the releases section and app demo video*

---

## 🚀 Features Built

### 1. Smart Bunk Manager
- Calculates exactly how many lectures you can safely miss (**Safe Zone** ✅) or must attend (**Danger Zone** 🔴) to stay above your target percentage
- Per subject tracking with Lecture / Tutorial / Practical weightage ratio — because not all class types count equally
- Color coded circular progress indicators — green when safe, red when danger

### 2. Calendar Dashboard
- See all your classes for any selected date
- Mark attendance as **Present**, **Absent**, or **Cancelled** with one tap
- Instant sync to Firebase Firestore

### 3. Push Notifications
- Daily attendance reminder via Firebase Cloud Messaging
- Configurable reminder time from settings

### 4. Authentication
- Google Sign-In via Firebase Auth
- Email/password login
- Guest mode for quick demo access (no login needed)

### 5. Weekly Timetable
- Add subjects with custom schedule, time slots, and faculty name
- App auto-populates the right classes for each day

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) — Material 3 |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Notifications | Firebase Cloud Messaging (FCM) |
| Design | Dark theme, Glassmorphism, Custom progress rings |

---

## ⚠️ Known Limitations (Honest)

- **Notifications** run on local triggers, not a 24/7 cloud server — so background push may not always fire for external users. This is a hosting cost constraint, not a code issue.
- **Assignment Hub** screen is UI only — logic planned for v1.1.0
- Not published on Play Store yet (₹1,750 developer fee pending)

---

## 🚧 Project Status: v1.0.1-beta

| Feature | Status |
|---|---|
| Attendance & Bunk Logic | Production-ready ✅ |
| Google Auth + Guest Access | Fully functional ✅ |
| Push Notifications | Working (local) ✅ |
| Weekly Timetable | Fully functional ✅ |
| Assignment Hub | UI mockup only ⏳ |
| Play Store Release | Planned ⏳ |

---

## 🧑‍💻 About the Developer

**Tirth Bisen**
B.Tech Computer Science and Engineering — Semester 1
Amity University

Built this in 4 days during **GDG TechSprint** hackathon. First major Flutter project. Learned Firebase integration, state management, and real-time sync through building this.

Currently also building an **audio streaming app** (AudioRelay-style) with real-time Opus encoding, UDP streaming, and sub-40ms latency — available on request.

*Open to internship opportunities in Flutter development or mobile app projects.*

---

## 📬 Contact

**GitHub:** [Tirthbisen](https://github.com/Tirthbisen)
