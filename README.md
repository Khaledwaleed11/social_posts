# 📱 Social Posts

A modern social media application built with **Flutter**, designed with a clean and scalable architecture.

The app allows users to create and share posts, upload images, interact with posts through likes and comments, and manage their profiles through a smooth and modern UI.

---

## ✨ Features

* 🔐 **Firebase Authentication**

  * User registration
  * User login
  * Persistent authentication state
  * Logout

* 📝 **Posts**

  * Create text posts
  * Add images to posts
  * Display posts in a modern feed
  * Delete your own posts
  * Display post creation time

* ❤️ **Likes**

  * Like / Unlike posts
  * Optimistic UI for instant feedback
  * Automatic rollback if the Firebase operation fails

* 💬 **Comments**

  * Add comments
  * Delete your own comments
  * Display comments in real time-like interactions
  * Optimistic UI for adding and deleting comments
  * Automatic comments count updates

* 👤 **Profile**

  * View profile information
  * Upload profile image
  * Update profile name
  * Display number of posts
  * Logout

* ☁️ **Cloud Image Storage**

  * Images are uploaded using **Cloudinary**
  * Firebase Storage is not required

* 🎨 **Modern UI**

  * Clean and professional design
  * Material 3
  * Consistent theme
  * Smooth animations
  * Loading skeletons
  * Empty states
  * Responsive layouts
  * Keyboard-aware screens

---

## 🛠️ Technologies & Packages

### Framework

* Flutter
* Dart

### Backend & Services

* Firebase Authentication
* Cloud Firestore
* Cloudinary

### State Management

* Flutter Bloc / Cubit

### Architecture & Dependency Management

* Clean Architecture
* GetIt
* Repository Pattern
* Use Case Pattern
* Dependency Injection

### Other Packages

* `equatable`
* `dartz`
* `image_picker`
* `http`

---

## 🏗️ Architecture

The project follows **Clean Architecture** to keep the codebase scalable, maintainable, and easy to test.

```text
lib/
│
├── core/
│   ├── animations/
│   ├── constants/
│   ├── dependency_injection/
│   ├── errors/
│   ├── storage/
│   └── theme/
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── posts/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── comments/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── app/
│   └── app.dart
│
└── main.dart
```

### Clean Architecture Layers

**Presentation**

Contains:

* Screens
* Widgets
* Cubits
* States

**Domain**

Contains:

* Entities
* Repository contracts
* Use Cases

**Data**

Contains:

* Models
* Remote Data Sources
* Repository implementations

This separation keeps business logic independent from the UI and external services.

---

## ⚡ Optimistic UI

One of the main concepts implemented in this project is **Optimistic UI**.

For example, when a user likes a post:

```text
User taps Like
       ↓
UI updates immediately ❤️
       ↓
Firebase operation runs
       ↓
Success → Keep the new state
       ↓
Failure → Rollback to previous state
```

The same approach is also used when adding and deleting comments.

This makes the application feel faster and more responsive while still keeping the backend state consistent.

---

## 🔥 Firebase

Firebase is used for:

* Authentication
* User profiles
* Posts
* Likes
* Comments
* Post metadata

Firestore structure:

```text
users/
    {userId}

posts/
    {postId}
        comments/
            {commentId}
```

---

## ☁️ Cloudinary

Post and profile images are uploaded to **Cloudinary** instead of Firebase Storage.

```text
Flutter
   ↓
Image Picker
   ↓
Cloudinary
   ↓
Secure Image URL
   ↓
Firestore
```

The returned image URL is stored in Firestore and used by the application to display the uploaded image.

---

## 📸 Screenshots

### 1. Home Feed

 <p align="center">

<img width="300" height="900" alt="social_home" src="https://github.com/user-attachments/assets/ab2753ce-524a-48e8-8dfe-339b0b6b4da9" />
<p>


---
<p align="center">

### 2. Create Post

<img width="300" height="900" alt="social_create_post" src="https://github.com/user-attachments/assets/821818dc-8b50-4b35-b1d7-5202d70fa6f5" />
<p>

---

### 3. Comments
<p align="center">

<img width="300" height="900" alt="social_comments" src="https://github.com/user-attachments/assets/be63334b-f3f6-4a21-90ff-7fe1c5696d17" />
<p>

---

### 4. Profile
<p align="center">

<img width="300" height="900" alt="social_profile" src="https://github.com/user-attachments/assets/7255ab31-06dc-4222-8d31-cf180b03e527" />
<p>

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/social_posts.git
```

### 2. Navigate to the project

```bash
cd social_posts
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Connect the project to your Firebase project and make sure Firebase Authentication and Cloud Firestore are enabled.

### 5. Configure Cloudinary

Create an unsigned upload preset and configure the Cloudinary credentials inside the image storage data source.

### 6. Run the application

```bash
flutter run
```

---

## 🔐 Security Notes

The application uses Firebase Authentication to identify users.

Firestore security rules should be configured to ensure that users can only modify resources they are authorized to modify.

Cloudinary is configured using an **unsigned upload preset**, so sensitive API secrets are not included inside the Flutter application.

---

## 📚 What I Practiced

Through this project, I practiced and applied:

* Flutter Clean Architecture
* Cubit & State Management
* Firebase Authentication
* Cloud Firestore
* Cloudinary Image Upload
* Repository Pattern
* Use Case Pattern
* Dependency Injection
* GetIt
* Optimistic UI
* Error Handling
* Form Validation
* Image Picking
* Responsive UI
* Animations
* Loading States
* Empty States
* Keyboard Handling
* Git & GitHub

---

## 🎯 Project Goal

The goal of this project was not only to build a social media application, but also to practice building a Flutter application using a **real-world architecture and development approach**.

The project focuses on keeping the codebase organized, scalable, and easy to maintain while providing a smooth user experience.

---

## 👨‍💻 Developer

**Khaled Waleed**

Flutter Developer

### Connect With Me

* LinkedIn: https://www.linkedin.com/in/khaled-waleed-713511248/
* GitHub: https://github.com/Khaledwaleed11

---

## ⭐ Support

If you found this project useful or interesting, feel free to give it a ⭐ on GitHub.
