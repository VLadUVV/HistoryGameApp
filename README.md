History Game — Educational Historical Quiz App

History Game is a cross-platform application built with Flutter that helps users explore Russian and World History
through interactive mini-games.
The app includes user profiles, quiz mechanics, and history period selection to personalize the experience.
Cross-Platform Support
This application is developed using Flutter, which allows deployment on:

    Android (primary target, tested)
    iOS
    Windows
    Linux
    macOS
    Web

The project uses cross-platform compatible packages like shared_preferences and audioplayers.
Minor adjustments (e.g., Info.plist for iOS audio permissions)
may be required for full multi-platform deployment.

History period and type selection (Ancient, Medieval, Modern, Contemporary; Russian or World History)
    Quiz game with:
        Countdown timer for each question
        Scoring system
        Persistent best score saved via SharedPreferences

    Upcoming games (in development):
        Find 10 Differences
        Guess the Event by Emoji

    User account system:
        Registration
        Login
        Profile editing

    Audio feedback for correct and incorrect answers
    Themed background on all screens

Project Structure

    lib/
    ├── main.dart
    ├── models/
    │   └── quiz_question.dart
    │   └── user_data.dart
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── main_screen.dart
    │   ├── profile_screen.dart
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── edit_profile_screen.dart
    │   ├── era_selection_screen.dart
    │   ├── game_selector_screen.dart
    │   ├── quiz_screen.dart
    │   ├── emoji_guess_screen.dart
    │   └── game_10_differences.dart
    ├── widgets/
    │   └── button_style.dart

Getting Started

    Install Flutter SDK
    Clone the repository:

    git clone https://github.com/your-username/history-game.git
    cd history-game

Install dependencies:

    flutter pub get
Run the app on a connected device or emulator:

    flutter run
    Use flutter run -d chrome for Web or -d windows/macos/linux for desktop testing.

Dependencies

    dependencies:
    flutter:
    audioplayers: ^5.2.1
    shared_preferences: ^2.2.0
    cupertino_icons: ^1.0.8

Assets

    assets:
    - assets/images/fon_main.jpg
    - assets/images/logo_profile.jpg
    - assets/audio/correct.mp3
    - assets/audio/wrong.mp3

Future Plans:

    Integrate Firebase Authentication for secure user login and registration
    Store quiz questions and player progress in Cloud Firestore
    Implement online leaderboards and competitive mode using real-time updates
    Expand quiz content: more questions, new difficulty levels, and game modes
    Add user-generated questions and community content system
    Introduce admin panel (web-based) to manage questions and players
    Enable cloud sync across devices using Firebase

Author:

    Vladislav Ungefuk
    Email: ungefuk.vlad@mail.ru
    Position: Full-stack developer, student
    Repository: github.com/VLadUVV
