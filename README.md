# 🩸 VitaFlow — Smart Blood Donation & Delivery System

> A real-time, role-based platform that connects **Donors, Doctors, and Riders** to ensure fast and reliable blood delivery.

---

## 🚨 Problem Statement

Traditional blood donation systems suffer from:
- Lack of real-time coordination  
- Delayed emergency response  
- No proper tracking of delivery  

---

## 💡 Solution

VitaFlow provides:
- Smart matching between donors and requests  
- Rider-based delivery system  
- Real-time tracking  
- Secure OTP-based verification  

---

## 🧠 Core Idea

This is not just a CRUD app. It combines:
- Location-based matching  
- Multi-role workflows  
- Logistics tracking  
- Real-world emergency handling  

---

## ⚙️ System Architecture

```
Flutter App (Frontend)
        ↓
 REST API (Spring Boot)
        ↓
 PostgreSQL Database
```

---

## 👥 User Roles

### 🧑‍⚕️ Doctor
- Create blood requests  
- Track delivery  
- View history  

### 🧑 Donor
- View nearby requests  
- Accept and donate  
- Track contributions  

### 🚴 Rider
- Accept delivery tasks  
- Pickup and deliver blood  
- Verify delivery using OTP  

---

## ✨ Features

- 🔐 OTP Authentication (SMS)  
- 📍 Real-Time Location Tracking (Google Maps)  
- 🔄 Smart Matching System  
- 📦 Delivery Lifecycle Tracking  
- 📊 Role-Based Dashboards  
- 📜 History Tracking  

---

## 📸 Screenshots

> ⚠️ Replace these with real images from your app

### Login Screen
![Login](assets/login.png)

### Doctor Dashboard
![Doctor](assets/doctor_dashboard.png)

### Donor Requests
![Donor](assets/donor_requests.png)

### Rider Tracking
![Rider](assets/rider_tracking.png)

---

## 🛠 Tech Stack

### Frontend
- Flutter  
- Google Maps SDK  
- Geolocator  
- HTTP  

### Backend
- Spring Boot (Java 21)  
- Spring Security  
- Spring Data JPA (Hibernate)  
- PostgreSQL  
- Twilio (OTP Service)  

---

## 📂 Project Structure

```
VitaFlow/
├── frontend/
│   └── lib/
│       ├── screens/
│       ├── services/
│       └── main.dart
│
├── backend/
│   ├── controllers/
│   ├── services/
│   ├── repositories/
│   ├── entities/
│   └── config/
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK  
- Java 21  
- Maven  
- PostgreSQL  

---

### Run Backend

```bash
cd backend
mvn spring-boot:run
```

Configure database in:
```
backend/src/main/resources/application.properties
```

---

### Run Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## 🔐 Environment Setup

Make sure to configure:
- Twilio credentials  
- Email service  
- Google Maps API key  

Without these, core features will not work.

---

## 🧪 Example Workflow

1. Doctor creates a blood request  
2. Nearby donors receive request  
3. Donor accepts  
4. Rider gets assigned  
5. Rider picks up blood  
6. OTP verification  
7. Delivery completed  

---

## 🚧 Limitations

- No production deployment yet  
- Basic matching logic  
- Limited security (can be improved)  
- No push notifications  

---

## 📈 Future Improvements

- AI-based donor matching  
- Firebase notifications  
- Admin dashboard  
- Analytics system  

---

## 🤝 Contributing

```bash
git checkout -b feature/your-feature
git commit -m "Add feature"
git push origin feature/your-feature
```

---

## 📜 License

Open-source for learning and improvement.
