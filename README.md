
# 🛡️ SafeWalk – Personal Safety App

**SafeWalk** is a mobile application built with Flutter to enhance personal safety for students and individuals walking alone. It allows real-time trip tracking, emergency alerts, and shake-triggered SOS notifications to pre-saved contacts.

---

## 📱 Features

| Feature                         | Description                                                                 |
|---------------------------------|-----------------------------------------------------------------------------|
| 🚶‍♂️ **Trip Tracking**            | Start and end trip sessions using GPS location tracking                   |
| 🆘 **Emergency Button**         | Instantly notify emergency contacts with your live location               |
| 📳 **Shake-to-Send Alert**      | Send a quick SOS alert by simply shaking your device                      |
| 📍 **Live Location Sharing**    | Share your current location with selected contacts in real time (planned) |
| 📔 **Trip History**             | View records of previous trips (planned)                                   |
| ⚙️ **Settings & Sensitivity**   | Manage preferences including shake sensitivity and alert toggles          |

---

## 🧰 Tech Stack

- **Flutter** – Cross-platform UI framework
- **Google Maps Flutter** – Embedded map for live tracking
- **Geolocator** – GPS positioning
- **Sensors Plus** – Accelerometer access for shake detection
- **Firebase (Planned)** – For storing trip logs and user data
- **Shared Preferences** – Local state and settings storage

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio (for emulator) or physical device
- VS Code (or preferred IDE)
- Google Maps API Key (for map functionality)

### Clone and Run

```bash
git clone https://github.com/atiteck-world/safewalk.git
cd safewalk
flutter pub get
flutter run
```

> 🔐 **Don't forget** to add your `google-services.json` and API keys where required.

---

## 📂 Project Structure

```
/lib
 ┣ /screens                # UI screens
 ┃ ┣ home_screen.dart
 ┃ ┣ trip_tracker_screen.dart
 ┃ ┣ emergency_contacts_screen.dart
 ┃ ┗ settings_screen.dart
 ┣ /services               # Location, alerts, Firebase (planned)
 ┣ /models                 # Data models
 ┣ main.dart               # Entry point
```

---

## 📸 Screenshots (Coming Soon)

_Add screenshots or screen recordings of your app here._

---

## 🔒 Permissions

SafeWalk requests the following permissions:

- 📍 **Location Access** (Foreground)
- 📳 **Sensor Access** (Accelerometer)
- 📤 **Internet Access** (for live location sharing, Firebase integration)

---

## 👨‍💻 Author

**Bismark Azumah Atiim**  
📍 Germany | 🌍 Ghana  
💼 [LinkedIn](https://linkedin.com/in/ba_atiim) | 💻 [GitHub](https://github.com/atiteck-world)

---

## 🏗️ Roadmap

- [x] Home UI
- [ ] Trip Tracker screen with GPS
- [ ] Emergency Contacts manager
- [ ] Shake-to-send alert
- [ ] Trip history
- [ ] Firebase integration for user data
