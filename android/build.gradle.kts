allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension != null) {
            val android = androidExtension as com.android.build.gradle.BaseExtension
            
            // Forces all plugins (including optimize_battery) to SDK 34
            android.compileSdkVersion(34)
            
            // Injects the missing namespace required by Gradle 8.0+
            if (android.namespace == null) {
                android.namespace = project.group.toString().ifEmpty { "com.example.${project.name.replace("-", "_")}" }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}