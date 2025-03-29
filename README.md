# TrimTime - Barber Shop Appointment App

## 📌 Overview
**TrimTime** is a Flutter-based mobile application that allows users to book appointments at a barber shop. It includes user authentication, service selection, time slot management, and an admin dashboard for handling bookings.

## 🚀 Features
- **User Authentication:** Sign up, log in, and logout using Firebase Authentication.  
- **Book Appointments:** Users can select a service, choose a time slot, and book an appointment.  
- **Manage Services:** Admins can add, edit, and delete available services.  
- **Manage Time Slots:** Admins can add, edit, and delete available time slots.  
- **Booking History:** Users can view their past and pending bookings.  
- **Admin Dashboard:** Admins can approve or decline appointments.  

## 🛠️ Tech Stack
- **Flutter (Dart)** - Frontend framework  
- **Firebase Authentication** - User login and signup  
- **Cloud Firestore** - Storing user data and appointments  
- **Firebase Core** - App initialization  

## 📂 Project Structure
```
/lib
│── main.dart             # App entry point
│── auth_service.dart     # Handles authentication logic
│── login.dart            # User login screen
│── signup.dart           # User signup screen
│── dashboard.dart        # User dashboard for booking appointments
│── history.dart          # Displays booking history
│── changeSlots.dart      # Admin panel to manage time slots
│── changeServices.dart   # Admin panel to manage services
│── admindashboard.dart   # Admin dashboard for managing appointments
│── wrapper.dart          # Redirects users based on authentication state
```

## 🔧 Setup Instructions
1. **Clone the repository:**  
   ```sh
   git clone https://github.com/your-repo.git
   cd your-repo
   ```
2. **Install dependencies:**  
   ```sh
   flutter pub get
   ```
3. **Set up Firebase:**  
   - Add your Firebase project to Flutter.  
   - Configure `google-services.json` (for Android) and `FirebaseOptions` in `main.dart`.  

4. **Run the application:**  
   ```sh
   flutter run
   ```

## 🏗️ Future Improvements
- **Payment Integration** for seamless transactions  
- **Push Notifications** for appointment updates  
- **Enhanced UI/UX** with animations and better accessibility  

---
