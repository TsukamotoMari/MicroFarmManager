plugins {
	id("com.android.library")
}

val pluginName = "UpdateInstaller"
val pluginPackageName = "com.devinaigames.microfarm.updateinstaller"

android {
	namespace = pluginPackageName
	compileSdk = 35

	defaultConfig {
		minSdk = 24
		manifestPlaceholders["godotPluginName"] = pluginName
		manifestPlaceholders["godotPluginPackageName"] = pluginPackageName
		setProperty("archivesBaseName", pluginName)
	}

	compileOptions {
		sourceCompatibility = JavaVersion.VERSION_17
		targetCompatibility = JavaVersion.VERSION_17
	}
}

dependencies {
	implementation("org.godotengine:godot:4.7.2.stable")
	implementation("androidx.core:core:1.15.0")
}

val copyReleaseAar by tasks.registering(Copy::class) {
	from("build/outputs/aar")
	include("$pluginName-release.aar")
	into("../../addons/UpdateInstaller/bin/release")
}

val copyDebugAar by tasks.registering(Copy::class) {
	from("build/outputs/aar")
	include("$pluginName-debug.aar")
	into("../../addons/UpdateInstaller/bin/debug")
}

tasks.named("assemble").configure {
	finalizedBy(copyReleaseAar, copyDebugAar)
}
