# Vita Flow 🩸

Vita Flow is a modern blood donation platform designed to bridge the gap between donors, doctors/hospitals, and riders. It ensures timely delivery of life-saving blood by facilitating role-based coordination and real-time tracking.

## 🚀 Overview

The project consists of a high-performance **Flutter** mobile application and a robust **Spring Boot** backend. It handles different user roles (Donors, Doctors, Riders) with specialized workflows for each.

## ✨ Key Features

- **Role-Based Access**: Specialized interfaces for Donors, Doctors, and Riders.
- **Real-Time Location**: Integrated Google Maps for location picking and delivery tracking.
- **Blood Request Management**: Doctors can create requests, Riders can accept and fulfill them.
- **Secure Authentication**: Phone-based OTP authentication system.
- **History Tracking**: View past donations and delivery history.
- **Role-Specific Dashboards**: Clean and intuitive UIs for managing tasks.

## 🛠 Tech Stack

### Frontend

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Provider / Local State
- **Key Packages**: `google_maps_flutter`, `geolocator`, `fl_chart`, `http`, `intl`.

### Backend

- **Framework**: [Spring Boot 4.x](https://spring.io/projects/spring-boot)
- **Language**: Java 21
- **Database**: PostgreSQL
- **Security**: Spring Security
- **Data Access**: Spring Data JPA / Hibernate

---

## 📂 Project Structure

```text
Vita_Flow/
├── frontend/               # Flutter Mobile Application
│   ├── lib/
│   │   ├── screens/        # UI Screens (Doctor, Donor, Rider)
│   │   ├── services/       # API Integration
│   │   └── main.dart       # Entry point
│   └── pubspec.yaml        # Frontend dependencies
└── backend/                # Spring Boot REST API
    ├── src/main/java/      # Java Source Code
    ├── src/main/resources/ # Configuration (application.properties)
    └── pom.xml             # Backend dependencies
```

---

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Java 21 JDK](https://www.oracle.com/java/technologies/downloads/)
- [Maven](https://maven.apache.org/download.cgi)
- [PostgreSQL](https://www.postgresql.org/download/)

### Backend Setup

1. Navigate to the `backend` directory.
2. Configure your database in `src/main/resources/application.properties`.
3. Run the application:
   ```bash
   mvn spring-boot:run
   ```

### Frontend Setup

1. Navigate to the `frontend` directory.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
