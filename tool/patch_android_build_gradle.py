#!/usr/bin/env python3
"""
Patches android/app/build.gradle(.kts) after `flutter create` to enable
core library desugaring required by flutter_local_notifications.
Handles both Groovy DSL (build.gradle) and Kotlin DSL (build.gradle.kts).
"""
import re, sys, os

GROOVY = 'android/app/build.gradle'
KOTLIN = 'android/app/build.gradle.kts'

# Determine which file exists
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

print("=== build.gradle content ===")
print(content)
print("=== end ===")

# Guard: skip if already patched
if 'coreLibraryDesugaring' in content:
    print('Already patched — skipping.')
    sys.exit(0)

if is_kts:
    # Kotlin DSL syntax
    DESUGARING_FLAG = 'isCoreLibraryDesugaringEnabled = true'
    DESUGARING_DEP  = '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")'
else:
    # Groovy DSL syntax
    DESUGARING_FLAG = 'coreLibraryDesugaringEnabled true'
    DESUGARING_DEP  = "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'"

# ── 1. Add flag inside compileOptions ────────────────────────────────────────
if 'compileOptions' in content:
    content = re.sub(
        r'(compileOptions\s*\{)',
        r'\1\n        ' + DESUGARING_FLAG,
        content,
        count=1,
    )
else:
    print('WARNING: compileOptions block not found — build may still fail.')

# ── 2. Add desugar dependency ─────────────────────────────────────────────────
if re.search(r'dependencies\s*\{', content):
    content = re.sub(
        r'(dependencies\s*\{)',
        r'\1\n' + DESUGARING_DEP,
        content,
        count=1,
    )
else:
    # No dependencies block: append one at the end
    content = content.rstrip() + f'\n\ndependencies {{\n{DESUGARING_DEP}\n}}\n'

with open(path, 'w') as f:
    f.write(content)

print(f'{path} patched successfully.')
