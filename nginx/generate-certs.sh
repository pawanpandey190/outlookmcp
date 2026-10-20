#!/bin/bash
set -e

CERT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/certs"
mkdir -p "$CERT_DIR"

if [ -f "$CERT_DIR/server.crt" ] && [ -f "$CERT_DIR/server.key" ]; then
  echo "[SKIP] SSL certificate already exists in $CERT_DIR"
  exit 0
fi

echo "[GENERATE] Creating self-signed SSL certificate in $CERT_DIR..."

IP="${1:-127.0.0.1}"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.crt" \
  -subj "/CN=ms365-mcp" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:$IP"

chmod 600 "$CERT_DIR/server.key"
chmod 644 "$CERT_DIR/server.crt"

echo "[DONE] SSL certificate generated successfully."
echo "  Certificate: $CERT_DIR/server.crt"
echo "  Private Key: $CERT_DIR/server.key"
