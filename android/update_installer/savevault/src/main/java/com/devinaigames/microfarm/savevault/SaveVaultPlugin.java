package com.devinaigames.microfarm.savevault;

import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.collection.ArraySet;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Set;

public class SaveVaultPlugin extends GodotPlugin {
	private static final String FOLDER = "MicroFarmManager";
	private static final String FILE_NAME = "micro-farm-save-v1.json";

	public SaveVaultPlugin(Godot godot) {
		super(godot);
	}

	@Override
	@NonNull
	public String getPluginName() {
		return "SaveVault";
	}

	@NonNull
	@Override
	public Set<SignalInfo> getPluginSignals() {
		Set<SignalInfo> signals = new ArraySet<>();
		signals.add(new SignalInfo("save_vault_write_finished", Boolean.class, String.class));
		signals.add(new SignalInfo("save_vault_read_finished", Boolean.class, String.class, Boolean.class));
		return signals;
	}

	@UsedByGodot
	public void writeSave(String json) {
		if (json == null || json.isEmpty()) {
			emitSignal("save_vault_write_finished", false, "Missing save data");
			return;
		}
		new Thread(() -> {
			try {
				try {
					writeFile(json);
				} catch (Exception ignored) {
					// Scoped storage may block the public Documents path; MediaStore is enough.
				}
				writeMediaStore(json);
				emitSignal("save_vault_write_finished", true, "");
			} catch (Exception error) {
				String message = error.getMessage() == null ? "Could not keep a cloud save" : error.getMessage();
				emitSignal("save_vault_write_finished", false, message);
			}
		}).start();
	}

	@UsedByGodot
	public void readSave() {
		new Thread(() -> {
			try {
				boolean exists = saveFile().exists() || findMediaStoreUri() != null;
				String json = readFile();
				if (json == null) {
					json = readMediaStore();
				}
				if (json != null && !json.isEmpty()) {
					exists = true;
					emitSignal("save_vault_read_finished", true, json, exists);
				} else {
					emitSignal("save_vault_read_finished", false, "", exists);
				}
			} catch (Exception error) {
				String message = error.getMessage() == null ? "Could not read cloud save" : error.getMessage();
				emitSignal("save_vault_read_finished", false, message, false);
			}
		}).start();
	}

	@UsedByGodot
	public void clearSave() {
		new Thread(() -> {
			try {
				File file = saveFile();
				if (file.exists()) {
					//noinspection ResultOfMethodCallIgnored
					file.delete();
				}
				Uri uri = findMediaStoreUri();
				if (uri != null) {
					getActivity().getContentResolver().delete(uri, null, null);
				}
				emitSignal("save_vault_write_finished", true, "");
			} catch (Exception error) {
				String message = error.getMessage() == null ? "Could not clear cloud save" : error.getMessage();
				emitSignal("save_vault_write_finished", false, message);
			}
		}).start();
	}

	@UsedByGodot
	public void prepareRestore() {
		runOnHostThread(() -> {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
				Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
				intent.setData(Uri.parse("package:" + getActivity().getPackageName()));
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				getActivity().startActivity(intent);
			}
		});
	}

	private File saveDir() {
		return new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS), FOLDER);
	}

	private File saveFile() {
		return new File(saveDir(), FILE_NAME);
	}

	private void writeFile(String json) throws Exception {
		File dir = saveDir();
		if (!dir.exists() && !dir.mkdirs() && !dir.exists()) {
			return;
		}
		File file = saveFile();
		try (FileOutputStream out = new FileOutputStream(file)) {
			out.write(json.getBytes(StandardCharsets.UTF_8));
		}
	}

	private String readFile() throws Exception {
		File file = saveFile();
		if (!file.exists()) {
			return null;
		}
		try (FileInputStream in = new FileInputStream(file)) {
			return readStream(in);
		}
	}

	private void writeMediaStore(String json) throws Exception {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			return;
		}
		byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
		Uri existing = findMediaStoreUri();
		if (existing != null) {
			try (OutputStream out = getActivity().getContentResolver().openOutputStream(existing, "wt")) {
				if (out != null) {
					out.write(bytes);
					return;
				}
			}
		}
		ContentValues values = new ContentValues();
		values.put(MediaStore.MediaColumns.DISPLAY_NAME, FILE_NAME);
		values.put(MediaStore.MediaColumns.MIME_TYPE, "application/json");
		values.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOCUMENTS + "/" + FOLDER + "/");
		Uri uri = getActivity().getContentResolver().insert(
			MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
			values
		);
		if (uri == null) {
			return;
		}
		try (OutputStream out = getActivity().getContentResolver().openOutputStream(uri)) {
			if (out != null) {
				out.write(bytes);
			}
		}
	}

	private String readMediaStore() throws Exception {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			return null;
		}
		Uri uri = findMediaStoreUri();
		if (uri == null) {
			return null;
		}
		try (InputStream in = getActivity().getContentResolver().openInputStream(uri)) {
			return in == null ? null : readStream(in);
		}
	}

	private Uri findMediaStoreUri() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			return null;
		}
		String selection = MediaStore.MediaColumns.DISPLAY_NAME + "=?";
		String[] args = new String[] { FILE_NAME };
		try (Cursor cursor = getActivity().getContentResolver().query(
			MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
			new String[] { MediaStore.MediaColumns._ID },
			selection,
			args,
			null
		)) {
			if (cursor != null && cursor.moveToFirst()) {
				long id = cursor.getLong(0);
				return Uri.withAppendedPath(
					MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
					Long.toString(id)
				);
			}
		}
		return null;
	}

	private String readStream(InputStream in) throws Exception {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		byte[] buf = new byte[4096];
		int n;
		while ((n = in.read(buf)) > 0) {
			out.write(buf, 0, n);
		}
		return out.toString(StandardCharsets.UTF_8.name());
	}
}
