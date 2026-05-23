allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Override subproject compileSdk BEFORE evaluation dependency is declared
subprojects {
    afterEvaluate {
        val isAndroid = plugins.hasPlugin("com.android.application") || 
                        plugins.hasPlugin("com.android.library")
        if (isAndroid) {
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
