# Academix 🎓
**Smart Attendance Tracker & Bunk Manager**

Academix is a modern, high-performance Flutter application designed for college students to manage their class attendance effortlessly. It features a sleek dark-themed UI, real-time analytics, and cloud-integrated reminders.



## 🚀 Key Features

### 1. Dashboard & Smart Bunk Manager
* **The "Bunk" Logic:** Automatically calculates exactly how many lectures you can safely miss (**Safe Zone**) or how many you must attend (**Danger Zone**) to maintain your target percentage.
* **Live Analytics:** Dynamic progress rings provide a visual overview of your standing in every subject at a glance.
* **Interactive History:** Mark attendance as **Present**, **Absent**, or **Cancelled** for any specific date with instant cloud sync.

### 2. Smart Faculty Leave Requests (v1.0.1)
* **Automated Email Generation:** One-tap professional email drafting that pulls subject data and "Safe Zone" analytics to suggest optimal leave dates to faculty while keeping you above 75%.

### 3. Flexible Authentication (Judge-Ready)
* **Google Sign-In:** Secure authentication powered by **Firebase Auth**.
* **Guest Bypass:** A dedicated "Continue without login" mode specifically implemented for the **GDG TechSprint** to allow judges to explore the core features instantly without credential barriers.

## 🛠️ Tech Stack
* **Frontend:** Flutter (Dart) - *Material 3 & Glassmorphism*
* **Backend:** Firebase Auth, Cloud Firestore
* **Notifications:** Firebase Cloud Messaging (FCM)
* **Hardware:** Developed and optimized on **Lenovo LOQ (Ryzen 7 7435HS, RTX 4060, 24GB RAM)**.

## ⚠️ Technical Constraint: Notification Delivery
> **Important:** The "Daily Poke" notification system currently operates via local triggers. Due to the absence of a dedicated 24/7 production server (VPS) for background cron-jobs, real-time cloud-pushed notifications may not trigger for all external users. This is a known infrastructure constraint resulting from current development funding limits and is slated for resolution in the v1.2.0 production deployment.



## 🚧 Project Status: v1.0.1-beta
* **Attendance & Bunk Logic:** Production-ready ✅
* **Guest Access:** Fully Functional ✅
* **Assignment Hub:** UI Mockup (Logic coming in v1.1.0) ⏳

## 💻 Developer
**Tirth Bisen**  
Amity University  
*B.Tech Computer Science and Engineering (Sem 1)*
