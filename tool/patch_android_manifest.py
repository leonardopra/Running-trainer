#!/usr/bin/env python3
"""
Patches android/app/src/main/AndroidManifest.xml after `flutter create`
to add the permissions and broadcast receivers required by
flutter_local_notifications.
"""
import re, sys

MANIFEST = 'android/app/src/main/AndroidManifest.xml'

PERMISSIONS = '\n'.join([
    '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
    '    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>',
    '    <uses-permission android:name="android.permission.VIBRATE"/>',
    '    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>',
])

RECEIVERS = '''\
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>'''

try:
    with open(MANIFEST) as f:
        content = f.read()
except FileNotFoundError:
    print(f'ERROR: {MANIFEST} not found. Run flutter create first.', file=sys.stderr)
    sys.exit(1)

# Guard: skip if already patched
if 'flutter_local_notifications' in content:
    print('Manifest already patched — skipping.')
    sys.exit(0)

# Insert permissions immediately after the opening <manifest ...> tag
content = re.sub(
    r'(<manifest\b[^>]*>)',
    r'\1\n' + PERMISSIONS,
    content,
    count=1,
)

# Insert receivers before </application>
content = content.replace('</application>', RECEIVERS + '\n    </application>', 1)

with open(MANIFEST, 'w') as f:
    f.write(content)

print('AndroidManifest.xml patched successfully.')
