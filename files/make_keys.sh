#!/bin/bash
set -euo pipefail

# ==============================================================================
# Script to generate WireGuard keys and output them as a JSON fact file
# for use by Ansible. The generated fact file will be stored under 
# /etc/ansible/facts.d/wireguard.fact.
#
# The WireGuard keys (private and public) are generated in /etc/wireguard/keys,
# but if they already exist (or only one is missing), they will be regenerated.
# ==============================================================================

# ------------------------------------------------------------------------------
# Define directories and filenames.
# ------------------------------------------------------------------------------
FACTS_DIR='/etc/ansible/facts.d'
FACT_FILE="${FACTS_DIR}/wireguard.fact"
KEYS_DIR='/etc/wireguard/keys'

# ------------------------------------------------------------------------------
# Ensure that the WireGuard command exists.
# ------------------------------------------------------------------------------
if ! command -v wg &>/dev/null; then
  echo "Error: WireGuard (wg) command not found. Please install WireGuard." >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Function: generate_keys_json
#
# Generates WireGuard keys if necessary and outputs them in JSON format.
# This function checks for the existence of the keys and creates them if they
# do not exist or if any key is missing.
# ------------------------------------------------------------------------------
generate_keys_json() {
  # Create the keys directory if it does not exist.
  if [ ! -d "${KEYS_DIR}" ]; then
    mkdir -p "${KEYS_DIR}"
  fi

  # Generate keys if one or both files are missing.
  if [ ! -f "${KEYS_DIR}/privatekey" ] || [ ! -f "${KEYS_DIR}/publickey" ]; then
    pushd "${KEYS_DIR}" > /dev/null || { echo "Error: Could not enter ${KEYS_DIR}" >&2; exit 1; }
    # Generate keys: the private key is saved to 'privatekey' and the public key to 'publickey'.
    wg genkey | tee privatekey | wg pubkey > publickey
    # set strict permissions on the private key.
    chmod 600 privatekey
    popd > /dev/null
  fi

  # Output the keys in JSON format.
  cat <<EOF
{
  "private_key": "$(cat "${KEYS_DIR}/privatekey")",
  "public_key": "$(cat "${KEYS_DIR}/publickey")"
}
EOF
}

# ------------------------------------------------------------------------------
# Ensure the directory for Ansible facts exists.
# ------------------------------------------------------------------------------
if [ ! -d "${FACTS_DIR}" ]; then
  mkdir -p "${FACTS_DIR}"
fi

# ------------------------------------------------------------------------------
# Write the generated JSON output to the fact file.
# ------------------------------------------------------------------------------
generate_keys_json > "${FACT_FILE}"