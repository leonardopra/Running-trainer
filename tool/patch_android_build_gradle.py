#!/usr/bin/env python3
"""
Patches android/app/build.gradle after `flutter create` to enable
core library desugaring required by flutter_local_notifications.
Handles both old (apply plugin) and new (plugins {}) Flutter templates.
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

print("=== Original build.gradle ===")
print(content)
print("=== End ===")

# ── 1. Enable coreLibraryDesugaringEnabled in compileOptions ──────────────────
if 'compileOptions' in content:
    content = re.sub(
        r'(compileOptions\s*\{)',
        r'\1\n        coreLibraryDesugaringEnabled true',
        content,
        count=1,
    )
else:
    # No compileOptions block: inject one before the closing brace of android {}
    content = re.sub(
        r'(android\s*\{(?:[^{}]|\{[^{}]*\})*)\}',
        lambda m: m.group(0)[:-1] + (
            '\n    compileOptions {\n'
            '        coreLibraryDesugaringEnabled true\n'
            '        sourceCompatibility JavaVersion.VERSION_1_8\n'
            '        targetCompatibility JavaVersion.VERSION_1_8\n'
            '    }\n}'
        ),
        content,
        count=1,
        flags=re.DOTALL,
    )

# ── 2. Add desugar dependency ─────────────────────────────────────────────────
DESUGAR = "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'"

if re.search(r'dependencies\s*\{', content):
    content = re.sub(
        r'(dependencies\s*\{)',
        r'\1\n' + DESUGAR,
        content,
        count=1,
    )
else:
    # No dependencies block at all: append one
    content = content.rstrip() + f'\n\ndependencies {{\n{DESUGAR}\n}}\n'

with open(BUILD_GRADLE, 'w') as f:
    f.write(content)

print('build.gradle patched successfully.')
