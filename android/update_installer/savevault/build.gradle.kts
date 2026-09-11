plugins {
	id("com.android.library")
}

val pluginName = "SaveVault"
val pluginPackageName = "com.devinaigames.microfarm.savevault"

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
	implementation("androidx.annotation:annotation:1.9.1")
	implementation("androidx.collection:collection:1.4.5")
}

val copyReleaseAar by tasks.registering(Copy::class) {
	from("build/outputs/aar")
	include("$pluginName-release.aar")
	into("../../../addons/SaveVault/bin/release")
}

val copyDebugAar by tasks.registering(Copy::class) {
	from("build/outputs/aar")
	include("$pluginName-debug.aar")
	into("../../../addons/SaveVault/bin/debug")
}

tasks.named("assemble").configure {
	finalizedBy(copyReleaseAar, copyDebugAar)
}
