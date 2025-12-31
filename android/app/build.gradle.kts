plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
<<<<<<< HEAD
<<<<<<< HEAD
    namespace = "com.example.flutter_application_1"
=======
<<<<<<< HEAD
=======
>>>>>>> 9aede6ccb7c215ef9b1100fe59454f598f91af90
    namespace = "com.example.productivity_app"
=======
    namespace = "com.example.flutter_application_1"
>>>>>>> be46472 (Initial commit)
<<<<<<< HEAD
>>>>>>> 9aede6ccb7c215ef9b1100fe59454f598f91af90
=======
>>>>>>> 9aede6ccb7c215ef9b1100fe59454f598f91af90
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
<<<<<<< HEAD
<<<<<<< HEAD
        applicationId = "com.example.flutter_application_1"
=======
<<<<<<< HEAD
=======
>>>>>>> 9aede6ccb7c215ef9b1100fe59454f598f91af90
        applicationId = "com.example.productivity_app"
=======
        applicationId = "com.example.flutter_application_1"
>>>>>>> be46472 (Initial commit)
<<<<<<< HEAD
>>>>>>> 9aede6ccb7c215ef9b1100fe59454f598f91af90
=======
>>>>>>> 9aede6ccb7c215ef9b1100fe59454f598f91af90
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
