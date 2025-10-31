plugins {
    id("com.android.library") version "7.3.1"
}

group = "com.dexterous.flutterlocalnotifications"
version = "1.0-SNAPSHOT"

android {
    namespace = "com.dexterous.flutterlocalnotifications"
    compileSdk = 34
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        multiDexEnabled = true
        minSdk = 16
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    lintOptions {
        disable("InvalidPackage")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
    implementation("androidx.core:core:1.3.0")
    implementation("androidx.media:media:1.1.0")
    implementation("com.google.code.gson:gson:2.8.9")

    testImplementation("junit:junit:4.12")
    testImplementation("org.mockito:mockito-core:3.10.0")
    testImplementation("androidx.test:core:1.2.0")
    testImplementation("org.robolectric:robolectric:4.7.3")
}
