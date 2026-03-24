#!/usr/bin/env python3
"""
Patches android/app/build.gradle(.kts) after `flutter create` to add:
  1. key.properties loading (for release signing)
  2. signingConfigs.release block
  3. release buildType wired to release signingConfig
  4. compileSdk / targetSdk pinned to 34 (overrides flutter.compileSdkVersion)
  5. applicationId override (set via APP_ID env var, defaults to com.example.running_trainer_app)

Run AFTER patch_android_build_gradle.py.
"""
import re, sys, os

GROOVY = 'android/app/build.gradle'
KOTLIN = 'android/app/build.gradle.kts'

APP_ID = os.environ.get('APP_ID', 'com.example.running_trainer_app')

if os.path.exists(KOTLIN):
    path = KOTLIN
    is_kts = True
elif os.path.exists(GROOVY):
    path = GROOVY
    is_kts = False
else:
    print(f'ERROR: neither {GROOVY} nor {KOTLIN} found. Run flutter create first.', file=sys.stderr)
    sys.exit(1)

print(f'Found: {path}')

with open(path) as f:
    content = f.read()

# Guard: skip if already patched
if 'signingConfigs' in content and 'keystoreProperties' in content:
    print('Signing config already patched — skipping.')
    sys.exit(0)

if is_kts:
    # ── KTS patches ───────────────────────────────────────────────────────────

    # 1. Insert key.properties loader right after the plugins { } block
    KEYSTORE_LOADER = '''\
import java.util.Properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) load(keystorePropertiesFile.inputStream())
}

'''
    # Insert after the closing brace of the plugins block
    content = re.sub(
        r'(plugins\s*\{[^}]*\})',
        r'\1\n\n' + KEYSTORE_LOADER.strip(),
        content,
        count=1,
        flags=re.DOTALL,
    )

    # 2. Pin compileSdk to 34 (replace flutter.compileSdkVersion reference)
    content = re.sub(
        r'compileSdk\s*=\s*\S+',
        'compileSdk = 34',
        content,
    )

    # 3. Pin targetSdk to 34 in defaultConfig
    content = re.sub(
        r'targetSdk\s*=\s*\S+',
        'targetSdk = 34',
        content,
    )

    # 4. Override applicationId
    content = re.sub(
        r'applicationId\s*=\s*"[^"]*"',
        f'applicationId = "{APP_ID}"',
        content,
    )

    # 5. Add signingConfigs block before buildTypes
    SIGNING_CONFIGS_KTS = '''\
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
'''
    content = re.sub(
        r'(buildTypes\s*\{)',
        SIGNING_CONFIGS_KTS + r'    \1',
        content,
        count=1,
    )

    # 6. Wire release buildType to release signingConfig
    content = re.sub(
        r'(release\s*\{[^}]*?)signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        r'\1signingConfig = signingConfigs.getByName("release")',
        content,
        flags=re.DOTALL,
    )
    # If the release block doesn't already have a signingConfig line, add one
    if 'signingConfig = signingConfigs.getByName("release")' not in content:
        content = re.sub(
            r'(buildTypes\s*\{[^}]*?release\s*\{)',
            r'\1\n            signingConfig = signingConfigs.getByName("release")',
            content,
            count=1,
            flags=re.DOTALL,
        )

else:
    # ── Groovy patches ────────────────────────────────────────────────────────

    KEYSTORE_LOADER = '''\
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.withReader('UTF-8') { reader -> keystoreProperties.load(reader) }
}

'''
    # Insert at the very top of the file
    content = KEYSTORE_LOADER + content

    # 2. Pin compileSdkVersion to 34
    content = re.sub(
        r'compileSdkVersion\s+\S+',
        'compileSdkVersion 34',
        content,
    )

    # 3. Pin targetSdkVersion to 34
    content = re.sub(
        r'targetSdkVersion\s+\S+',
        'targetSdkVersion 34',
        content,
    )

    # 4. Override applicationId
    content = re.sub(
        r"applicationId\s+'[^']*'",
        f"applicationId '{APP_ID}'",
        content,
    )
    content = re.sub(
        r'applicationId\s+"[^"]*"',
        f'applicationId "{APP_ID}"',
        content,
    )

    # 5. Add signingConfigs block before buildTypes
    SIGNING_CONFIGS_GROOVY = '''\
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
'''
    content = re.sub(
        r'(buildTypes\s*\{)',
        SIGNING_CONFIGS_GROOVY + r'    \1',
        content,
        count=1,
    )

    # 6. Wire release buildType to release signingConfig
    content = re.sub(
        r'(release\s*\{[^}]*?)signingConfig\s+signingConfigs\.debug',
        r'\1signingConfig signingConfigs.release',
        content,
        flags=re.DOTALL,
    )
    if 'signingConfig signingConfigs.release' not in content:
        content = re.sub(
            r'(buildTypes\s*\{[^}]*?release\s*\{)',
            r'\1\n            signingConfig signingConfigs.release',
            content,
            count=1,
            flags=re.DOTALL,
        )

with open(path, 'w') as f:
    f.write(content)

print(f'{path} patched with signing config and SDK 34 successfully.')

# ── Patch AndroidManifest.xml — POST_NOTIFICATIONS permission (Android 13+) ──
MANIFEST = 'android/app/src/main/AndroidManifest.xml'
if os.path.exists(MANIFEST):
    with open(MANIFEST) as f:
        manifest = f.read()
    PERMISSION = '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>'
    if PERMISSION not in manifest:
        manifest = manifest.replace(
            '<application',
            f'{PERMISSION}\n    <application',
            1,
        )
        with open(MANIFEST, 'w') as f:
            f.write(manifest)
        print(f'{MANIFEST} patched with POST_NOTIFICATIONS permission.')
    else:
        print('POST_NOTIFICATIONS permission already present — skipping.')
else:
    print(f'WARNING: {MANIFEST} not found — run flutter create first.')
