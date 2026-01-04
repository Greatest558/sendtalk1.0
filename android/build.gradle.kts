plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
}
subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension != null) {
            val android = androidExtension as com.android.build.gradle.BaseExtension
            // Check if namespace is missing
            if (android.namespace == null) {
                // Assign a namespace based on the project group/name
                android.namespace = project.group.toString().ifEmpty { "com.example.${project.name.replace("-", "_")}" }
            }
        }
    }
}