#!/usr/bin/env python3
"""
Patches android/app/build.gradle after `flutter create` to enable
core library desugaring required by flutter_local_notifications.
"""
import re, sys

BUILD_GRADLE = 'android/app/build.gradle'

try:
    with open(BUILD_GRADLE) as f:
        content = f.read()
except FileNotFoundError:
    print(f'ERROR: {BUILD_GRADLE} not found. Run flutter create first.', file=sys.stderr)
    sys.exit(1)

# Guard: skip if already patched
if 'coreLibraryDesugaringEnabled' in content:
    print('build.gradle already patched — skipping.')
    sys.exit(0)

# Add coreLibraryDesugaringEnabled right after the opening brace of compileOptions
content = re.sub(
    r'(compileOptions\s*\{)',
    r'\1\n        coreLibraryDesugaringEnabled true',
    content,
    count=1,
)

# Add desugar dependency inside dependencies block
content = re.sub(
    r'(dependencies\s*\{)',
    r"\1\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'",
    content,
    count=1,
)

with open(BUILD_GRADLE, 'w') as f:
    f.write(content)

print('build.gradle patched successfully.')
