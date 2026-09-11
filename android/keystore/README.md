# Android signing keystore

This repo pins a single debug keystore so every local build and CI release uses the
same signature. Android only allows in-place APK updates when the signing certificate
matches the installed app.

| Field | Value |
| --- | --- |
| File | `debug.keystore` |
| Store password | `android` |
| Key alias | `androiddebugkey` |
| Key password | `android` |

The keystore in this folder is the one used for GitHub Releases. Do not replace it
unless you are intentionally breaking update compatibility for sideload installs.

For Google Play, create a separate release keystore and store it in GitHub Actions
secrets instead of committing it here.
