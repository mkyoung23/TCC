#!/usr/bin/env python3
"""Validate Codemagic signing environment variables locally.

Run this script before triggering a Codemagic build to confirm that all
required secrets are present and to see which optional values are still
missing. It exits with a non-zero status if any required variable is
absent so you can wire it into CI or local pre-flight checks easily.
"""

import os
import sys
from typing import Iterable, List, Tuple


REQUIRED_SOURCES = {
    "IOS_CERT_BASE64": (
        "IOS_CERT_BASE64",
        "CM_CERTIFICATE_BASE64",
        "CERTIFICATE_BASE64",
        "IOS_CERT_PATH",
        "IOS_CERT_FILE",
    ),
    "IOS_PROFILE_BASE64": (
        "IOS_PROFILE_BASE64",
        "CM_PROVISIONING_PROFILE_BASE64",
        "PROVISIONING_PROFILE_BASE64",
        "IOS_PROFILE_PATH",
        "IOS_PROFILE_FILE",
    ),
    "IOS_BUNDLE_ID": ("IOS_BUNDLE_ID",),
}

OPTIONAL_SOURCES = {
    "IOS_CERT_PASSWORD": ("IOS_CERT_PASSWORD",),
    "IOS_EXPORT_METHOD": ("IOS_EXPORT_METHOD",),
    "IOS_CODE_SIGN_IDENTITY": ("IOS_CODE_SIGN_IDENTITY",),
    "APPLE_TEAM_ID": ("APPLE_TEAM_ID",),
    "APP_STORE_CONNECT_KEY_ID": (
        "APP_STORE_CONNECT_KEY_ID",
        "APPSTORECONNECT_KEY_ID",
    ),
    "APP_STORE_CONNECT_ISSUER_ID": (
        "APP_STORE_CONNECT_ISSUER_ID",
        "APPSTORECONNECT_ISSUER_ID",
    ),
    "APP_STORE_CONNECT_API_KEY_BASE64": (
        "APP_STORE_CONNECT_API_KEY_BASE64",
        "APPSTORECONNECT_PRIVATE_KEY",
    ),
}


def _collect_defined(keys: Iterable[str]) -> List[str]:
    return [key for key in keys if os.environ.get(key)]


def _resolve_sources(mapping: dict) -> Tuple[List[Tuple[str, str]], List[str], List[str]]:
    ready: List[Tuple[str, str]] = []
    missing: List[str] = []
    fallbacks: List[str] = []

    for display_key, choices in mapping.items():
        defined = _collect_defined(choices)
        if defined:
            ready.append((display_key, defined[0]))
            if defined[0] != choices[0]:
                fallbacks.append(
                    f" • {display_key} provided via {defined[0]}"
                )
        else:
            missing.append(display_key)

    return ready, missing, fallbacks


def main() -> int:
    required_ready, missing_required, required_fallbacks = _resolve_sources(
        REQUIRED_SOURCES
    )
    optional_ready, _, optional_fallbacks = _resolve_sources(OPTIONAL_SOURCES)

    print("Codemagic signing environment check\n===============================")

    if required_ready:
        print("Ready to use:")
        for display_key, actual_key in required_ready:
            suffix = "" if display_key == actual_key else f" (via {actual_key})"
            print(f" • {display_key}{suffix}")
        print()

    if missing_required:
        print("Missing required values:")
        for key in missing_required:
            print(f" • {key}")
        print(
            "Add these to the ios_signing group in Codemagic or export them in your shell before running the workflow."
        )
        print()

    if optional_ready:
        print("Optional values detected:")
        for display_key, actual_key in optional_ready:
            suffix = "" if display_key == actual_key else f" (via {actual_key})"
            print(f" • {display_key}{suffix}")
        print()
    else:
        print("Optional values: (none found)")
        print(
            "Tip: Provide APP_STORE_CONNECT_* variables to enable automatic TestFlight uploads without UDIDs."
        )
        print()

    fallback_messages = required_fallbacks + optional_fallbacks
    if fallback_messages:
        print("Fallback sources in use:")
        for line in fallback_messages:
            print(line)
        print()

    if missing_required:
        print("❌ Codemagic signing secrets are incomplete.")
        return 1

    print("✅ All required Codemagic signing secrets are present.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
