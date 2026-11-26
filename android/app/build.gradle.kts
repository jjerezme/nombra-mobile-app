plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.jujeme.nombra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.jujeme.nombra"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 10+: files are saved to public folders through MediaStore, without storage permissions.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // AGP 9 turns resValues off by default; the flavors below set app_name through resValue.
    buildFeatures {
        resValues = true
    }

    // Two builds of the same app, each with its own Firebase project (see lib/core/environment.dart):
    //   dev  -> com.jujeme.nombra.dev, android/app/src/dev/google-services.json
    //   prod -> com.jujeme.nombra,     android/app/src/prod/google-services.json
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Nombra Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Nombra")
        }
    }

    // The upload key is given as Gradle properties (UPLOAD_STORE_FILE, UPLOAD_STORE_PASSWORD, UPLOAD_KEY_ALIAS,
    // UPLOAD_KEY_PASSWORD) by build-apk (mobile-tools), as ORG_GRADLE_PROJECT_* variables, so passwords never appear in a
    // command line. Without them the dev release keeps the debug signing (fine for local preview builds); the prod release
    // fails (see the end of this file).
    val hasUploadKey = project.hasProperty("UPLOAD_STORE_FILE")
    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                storeFile = file(project.property("UPLOAD_STORE_FILE") as String)
                storePassword = project.property("UPLOAD_STORE_PASSWORD") as String
                keyAlias = project.property("UPLOAD_KEY_ALIAS") as String
                keyPassword = project.property("UPLOAD_KEY_PASSWORD") as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasUploadKey) "upload" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Firebase plugins need the flavor's google-services.json (never versioned). A fresh checkout without them still
// builds; the app then starts without Firebase (see lib/core/bootstrap.dart).
if (listOf("dev", "prod").any { file("src/$it/google-services.json").exists() }) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}

// A production release (apk or bundle) must be signed with the upload key: it never falls back to the debug key.
gradle.taskGraph.whenReady {
    val isProdRelease = allTasks.any { task ->
        task.project == project &&
            task.name.endsWith("ProdRelease") &&
            listOf("assemble", "bundle", "package").any { task.name.startsWith(it) }
    }
    if (isProdRelease && !project.hasProperty("UPLOAD_STORE_FILE")) {
        throw GradleException(
            "A prod release needs the upload key (UPLOAD_STORE_FILE, UPLOAD_STORE_PASSWORD, UPLOAD_KEY_ALIAS, " +
                "UPLOAD_KEY_PASSWORD). Use build-apk with the key configured; see docs/BUILD.md.",
        )
    }
}
