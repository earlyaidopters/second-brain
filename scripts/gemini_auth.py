#!/usr/bin/env python3
"""
Centralized Gemini authentication for all scripts.

Supports two authentication methods:
1. API Key (via GOOGLE_API_KEY) — for Google AI Studio
2. Vertex AI (via GOOGLE_GENAI_USE_VERTEXAI) — for Google Cloud Platform

The google-genai library auto-detects which method to use based on environment variables.
This module validates that required variables are set and provides clear error messages.
"""

import os
import sys
from typing import Literal

try:
    from google import genai
except ImportError:
    print("Error: google-genai library not installed")
    print("Install with: pip install google-genai")
    sys.exit(1)


def get_auth_method() -> Literal["vertex_ai", "api_key"]:
    """
    Determine which authentication method is configured.

    Returns:
        "vertex_ai" if GOOGLE_GENAI_USE_VERTEXAI is set to true
        "api_key" otherwise (default)
    """
    use_vertex = os.environ.get("GOOGLE_GENAI_USE_VERTEXAI", "").lower()
    return "vertex_ai" if use_vertex in ("true", "1", "yes") else "api_key"


def _validate_api_key_auth() -> None:
    """Validate that API key authentication is properly configured."""
    api_key = os.environ.get("GOOGLE_API_KEY") or os.environ.get("GEMINI_API_KEY")

    if not api_key:
        print("Error: GOOGLE_API_KEY not set in environment")
        print()
        print("To use API Key authentication:")
        print("1. Get a free key at: https://aistudio.google.com/apikey")
        print("2. Add to your .env file:")
        print("   GOOGLE_API_KEY=your_key_here")
        print()
        print("Alternatively, use Vertex AI authentication (see README.md)")
        sys.exit(1)


def _validate_vertex_auth() -> None:
    """Validate that Vertex AI authentication is properly configured."""
    project = os.environ.get("GOOGLE_CLOUD_PROJECT")
    location = os.environ.get("GOOGLE_CLOUD_LOCATION")

    errors = []
    if not project:
        errors.append("GOOGLE_CLOUD_PROJECT is not set")
    if not location:
        errors.append("GOOGLE_CLOUD_LOCATION is not set")

    if errors:
        print("Error: Vertex AI authentication is enabled but incomplete")
        print()
        for error in errors:
            print(f"  ✗ {error}")
        print()
        print("To use Vertex AI authentication:")
        print("1. Set up a Google Cloud project with Vertex AI enabled")
        print("2. Add to your .env file:")
        print("   GOOGLE_GENAI_USE_VERTEXAI=true")
        print("   GOOGLE_CLOUD_PROJECT=your-project-id")
        print("   GOOGLE_CLOUD_LOCATION=us-central1")
        print("3. Authenticate with: gcloud auth application-default login")
        print()
        print("Alternatively, use API Key authentication (see README.md)")
        sys.exit(1)


def get_gemini_client() -> genai.Client:
    """
    Get a configured Gemini client with automatic authentication.

    Auto-detects which authentication method to use based on environment variables:
    - If GOOGLE_GENAI_USE_VERTEXAI=true → uses Vertex AI with GCP project/location
    - Otherwise → uses API key from GOOGLE_API_KEY or GEMINI_API_KEY

    Returns:
        genai.Client: Configured client ready to use

    Raises:
        SystemExit: If authentication is not properly configured
    """
    method = get_auth_method()

    # Validate that required environment variables are set for chosen method
    if method == "vertex_ai":
        _validate_vertex_auth()
    else:
        _validate_api_key_auth()

    # Let the library's auto-detection handle the rest
    # It will use the appropriate auth method based on environment variables
    try:
        client = genai.Client()
        return client
    except Exception as e:
        print(f"Error: Failed to create Gemini client")
        print(f"Details: {e}")
        print()
        if method == "vertex_ai":
            print("If you see authentication errors, try:")
            print("  gcloud auth application-default login")
        else:
            print("Check that your GOOGLE_API_KEY is valid")
        sys.exit(1)


if __name__ == "__main__":
    # Quick test of authentication setup
    print("Testing Gemini authentication...")
    print()

    method = get_auth_method()
    print(f"Detected method: {method}")
    print()

    if method == "vertex_ai":
        print("Vertex AI configuration:")
        print(f"  Project:  {os.environ.get('GOOGLE_CLOUD_PROJECT', '(not set)')}")
        print(f"  Location: {os.environ.get('GOOGLE_CLOUD_LOCATION', '(not set)')}")
    else:
        print("API Key configuration:")
        api_key = os.environ.get("GOOGLE_API_KEY", "")
        if api_key:
            print(f"  Key: {api_key[:10]}...{api_key[-4:] if len(api_key) > 14 else ''}")
        else:
            print("  Key: (not set)")

    print()
    print("Attempting to create client...")

    client = get_gemini_client()
    print("✓ Success! Client created successfully.")
    print()
    print(f"You can now use the Gemini scripts with {method} authentication.")
