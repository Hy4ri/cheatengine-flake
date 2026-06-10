#!/usr/bin/env bash

set -euo pipefail

# -------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------

usage() {
  echo "Usage: $0 [version]"
  echo ""
  echo "  version   Optional. The new Cheat Engine version (e.g., 7.7)."
  echo "            If omitted, you will be prompted."
  exit 1
}

get_hash() {
  local url="$1"
  local temp_file
  temp_file=$(mktemp)

  if curl -sL "$url" -o "$temp_file" && [ -s "$temp_file" ]; then
    local raw_hash
    raw_hash=$(sha256sum "$temp_file" | cut -d' ' -f1)
    nix hash convert --hash-algo sha256 --to sri "$raw_hash"
  fi
  rm -f "$temp_file"
}

# -------------------------------------------------------------------
# Parse arguments
# -------------------------------------------------------------------
version=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      ;;
    *)
      if [[ -z "$version" ]]; then
        version="$1"
      else
        echo "Error: Unexpected argument: $1"
        usage
      fi
      shift
      ;;
  esac
done

# -------------------------------------------------------------------
# Get version
# -------------------------------------------------------------------
if [[ -z "$version" ]]; then
  read -p "Enter Cheat Engine version to update to (e.g., 7.7): " version
fi

if [[ -z "$version" ]]; then
  echo "Error: Version cannot be empty."
  exit 1
fi

# Build the version string without dots for the URL/filename
version_nodots="${version//./}"

echo "------------------------------------------------"
echo "Target Version: $version"
echo "------------------------------------------------"

# -------------------------------------------------------------------
# Download and hash
# -------------------------------------------------------------------
url="https://cheatengine.org/download/CheatEngineLinux${version_nodots}.zip"

echo "Downloading and calculating hash..."
echo "  URL: $url"
hash_sri=$(get_hash "$url")

if [[ -z "$hash_sri" ]]; then
  echo "Error: Failed to download from:"
  echo "  $url"
  echo "Check if the version number is correct."
  exit 1
fi
echo "  Hash: $hash_sri"

# -------------------------------------------------------------------
# Update package.nix
# -------------------------------------------------------------------
if [[ ! -f "package.nix" ]]; then
  echo "Error: package.nix not found in current directory."
  exit 1
fi

echo "Updating package.nix..."
temp_file=$(mktemp)

# Update version
sed "s/version = \".*\";/version = \"$version\";/" package.nix >"$temp_file"

# Update hash
sed -i "s|hash = \"sha256-.*\";|hash = \"$hash_sri\";|" "$temp_file"

mv "$temp_file" package.nix

# -------------------------------------------------------------------
# Update version.json
# -------------------------------------------------------------------
echo "Updating version.json..."
cat > version.json << EOF
{
  "version": "$version",
  "url": "$url"
}
EOF

# -------------------------------------------------------------------
# Update README.md badge link
# -------------------------------------------------------------------
if [[ -f "README.md" ]]; then
  echo "Updating README.md..."
  sed -i "s|cheatengine\.org/download/CheatEngineLinux[0-9]*\.zip|cheatengine.org/download/CheatEngineLinux${version_nodots}.zip|g" README.md
fi

echo "------------------------------------------------"
echo "Success! Updated to Cheat Engine version ${version}"
echo "  Hash: ${hash_sri}"
echo "  URL:  ${url}"
echo "------------------------------------------------"
