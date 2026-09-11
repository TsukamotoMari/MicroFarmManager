#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLUGIN_DIR="${ROOT_DIR}/android/update_installer"

cd "${PLUGIN_DIR}"

if [[ ! -x "./gradlew" ]]; then
	echo "Bootstrapping Gradle wrapper..."
	GRADLE_VERSION="8.11.1"
	wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O /tmp/gradle.zip
	unzip -q /tmp/gradle.zip -d /tmp
	/tmp/gradle-${GRADLE_VERSION}/bin/gradle wrapper --gradle-version "${GRADLE_VERSION}"
fi

chmod +x ./gradlew
./gradlew :plugin:assembleRelease :plugin:assembleDebug
echo "Built UpdateInstaller AARs in addons/UpdateInstaller/bin/"
