allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(
    rootProject.projectDir.parentFile.resolve("build").resolve(rootProject.name)
)

subprojects {
    project.layout.buildDirectory.set(
        rootProject.layout.buildDirectory.dir(project.name)
    )
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension != null) {
            val android = androidExtension as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = project.group.toString().ifEmpty { "com.example.${project.name}" }
            }
        }
    }
}

subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension != null) {
            val android = androidExtension as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                // This gives older plugins like optimize_battery a temporary ID so they can build
                android.namespace = project.group.toString().ifEmpty { "com.example.${project.name}" }
            }
        }
    }
}