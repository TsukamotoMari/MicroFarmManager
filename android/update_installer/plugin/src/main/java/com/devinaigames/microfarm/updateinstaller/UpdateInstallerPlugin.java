package com.devinaigames.microfarm.updateinstaller;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.collection.ArraySet;
import androidx.core.content.FileProvider;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Set;

public class UpdateInstallerPlugin extends GodotPlugin {
	private static final String TAG = "MicroFarmUpdate";
	private static final String APK_NAME = "microfarm-update.apk";
	private static final String META_NAME = "microfarm-update.version";

	public UpdateInstallerPlugin(Godot godot) {
		super(godot);
	}

	@Override
	@NonNull
	public String getPluginName() {
		return "UpdateInstaller";
	}

	@NonNull
	@Override
	public Set<SignalInfo> getPluginSignals() {
		Set<SignalInfo> signals = new ArraySet<>();
		signals.add(new SignalInfo("update_download_finished", Boolean.class, String.class));
		signals.add(new SignalInfo("update_install_finished", Boolean.class, Boolean.class, String.class));
		return signals;
	}

	@UsedByGodot
	public int getLocalVersionCode() {
		try {
			PackageManager pm = getActivity().getPackageManager();
			PackageInfo info = pm.getPackageInfo(getActivity().getPackageName(), 0);
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
				return (int) info.getLongVersionCode();
			}
			return info.versionCode;
		} catch (Exception error) {
			Log.w(TAG, "Could not read version code", error);
			return 0;
		}
	}

	@UsedByGodot
	public String getLocalVersionName() {
		try {
			PackageManager pm = getActivity().getPackageManager();
			PackageInfo info = pm.getPackageInfo(getActivity().getPackageName(), 0);
			return info.versionName == null ? "" : info.versionName;
		} catch (Exception error) {
			Log.w(TAG, "Could not read version name", error);
			return "";
		}
	}

	@UsedByGodot
	public void downloadUpdate(String url, String fallbackUrl, int versionCode) {
		new Thread(() -> {
			try {
				ensureApk(url, fallbackUrl, versionCode);
				emitSignal("update_download_finished", true, "");
			} catch (Exception error) {
				String message = error.getMessage() == null ? "Download failed" : error.getMessage();
				emitSignal("update_download_finished", false, message);
			}
		}).start();
	}

	@UsedByGodot
	public void openInstaller() {
		File apk = cachedApk();
		if (!isValidApk(apk)) {
			emitSignal("update_install_finished", false, false, "The update file is gone. Tap Download update again.");
			return;
		}

		if (needsInstallPermission()) {
			Intent settings = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES);
			settings.setData(Uri.parse("package:" + getActivity().getPackageName()));
			runOnHostThread(() -> getActivity().startActivity(settings));
			emitSignal("update_install_finished", true, false, "Turn on Allow from this source, come back, then tap Install now.");
			return;
		}

		runOnHostThread(() -> {
			try {
				launchInstaller(apk);
				emitSignal("update_install_finished", false, true, "Confirm the Android install screen.");
			} catch (Exception error) {
				String message = error.getMessage() == null ? "Could not open installer" : error.getMessage();
				emitSignal("update_install_finished", false, false, message);
			}
		});
	}

	private void launchInstaller(File apk) {
		Uri uri = FileProvider.getUriForFile(
			getActivity(),
			getActivity().getPackageName() + ".fileprovider",
			apk
		);
		Intent intent = new Intent(Intent.ACTION_VIEW);
		intent.setDataAndType(uri, "application/vnd.android.package-archive");
		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		intent.putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true);
		grantUri(intent, uri);
		getActivity().startActivity(intent);
	}

	private void grantUri(Intent intent, Uri uri) {
		PackageManager pm = getActivity().getPackageManager();
		List<ResolveInfo> matches = pm.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
		for (ResolveInfo info : matches) {
			getActivity().grantUriPermission(
				info.activityInfo.packageName,
				uri,
				Intent.FLAG_GRANT_READ_URI_PERMISSION
			);
		}
	}

	private boolean needsInstallPermission() {
		return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
			&& !getActivity().getPackageManager().canRequestPackageInstalls();
	}

	private File ensureApk(String url, String fallbackUrl, int versionCode) throws IOException {
		if (hasCachedApk(versionCode)) {
			return cachedApk();
		}
		try {
			File apk = download(url);
			writeMeta(versionCode);
			return apk;
		} catch (IOException first) {
			if (fallbackUrl == null || fallbackUrl.isEmpty() || fallbackUrl.equals(url)) {
				throw first;
			}
			File apk = download(fallbackUrl);
			writeMeta(versionCode);
			return apk;
		}
	}

	private boolean hasCachedApk(int versionCode) {
		File apk = cachedApk();
		File meta = cachedMeta();
		if (!isValidApk(apk) || !meta.exists() || versionCode <= 0) {
			return false;
		}
		try (FileInputStream in = new FileInputStream(meta)) {
			byte[] raw = new byte[(int) meta.length()];
			int read = in.read(raw);
			if (read <= 0) {
				return false;
			}
			return String.valueOf(versionCode).equals(new String(raw, 0, read, StandardCharsets.UTF_8).trim());
		} catch (IOException error) {
			return false;
		}
	}

	private void writeMeta(int versionCode) throws IOException {
		if (versionCode <= 0) {
			return;
		}
		try (FileOutputStream out = new FileOutputStream(cachedMeta())) {
			out.write(String.valueOf(versionCode).getBytes(StandardCharsets.UTF_8));
		}
	}

	private File download(String urlString) throws IOException {
		HttpURLConnection conn = openFollowingRedirects(urlString);
		File out = cachedApk();
		File tmp = new File(getActivity().getCacheDir(), APK_NAME + ".part");
		try (InputStream in = conn.getInputStream();
			 FileOutputStream fos = new FileOutputStream(tmp)) {
			byte[] buf = new byte[8192];
			int first = in.read(buf);
			if (first < 2 || buf[0] != 'P' || buf[1] != 'K') {
				throw new IOException("The download was not an APK. Try again in a moment.");
			}
			fos.write(buf, 0, first);
			int n;
			while ((n = in.read(buf)) > 0) {
				fos.write(buf, 0, n);
			}
		} finally {
			conn.disconnect();
		}
		if (out.exists() && !out.delete()) {
			throw new IOException("Could not replace the old update file");
		}
		if (!tmp.renameTo(out)) {
			throw new IOException("Could not save the update file");
		}
		return out;
	}

	private HttpURLConnection openFollowingRedirects(String urlString) throws IOException {
		String current = urlString;
		for (int hop = 0; hop < 8; hop++) {
			HttpURLConnection conn = (HttpURLConnection) new URL(current).openConnection();
			conn.setInstanceFollowRedirects(false);
			conn.setConnectTimeout(20000);
			conn.setReadTimeout(60000);
			conn.setRequestProperty(
				"User-Agent",
				"Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36"
			);
			conn.setRequestProperty("Accept", hop == 0 ? "application/octet-stream,*/*" : "*/*");
			conn.setRequestProperty("Accept-Encoding", "identity");
			int code = conn.getResponseCode();
			if (code >= 300 && code < 400) {
				String next = conn.getHeaderField("Location");
				conn.disconnect();
				if (next == null || next.isEmpty()) {
					throw new IOException("Update redirect failed");
				}
				current = new URL(new URL(current), next).toString();
				continue;
			}
			if (code >= 400) {
				conn.disconnect();
				throw new IOException("Update download failed (" + code + ")");
			}
			return conn;
		}
		throw new IOException("Too many redirects");
	}

	private File cachedApk() {
		Activity activity = getActivity();
		return new File(activity.getCacheDir(), APK_NAME);
	}

	private File cachedMeta() {
		Activity activity = getActivity();
		return new File(activity.getCacheDir(), META_NAME);
	}

	private static boolean isValidApk(File apk) {
		return apk != null && apk.isFile() && apk.length() > 100_000;
	}
}
