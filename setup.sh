#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# setup.sh — One-time VM setup for ms-365-mcp-server
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh <your-ai-app-container-name>
#
# Example:
#   ./setup.sh my-ai-app
# ─────────────────────────────────────────────────────────────────

set -e

AI_CONTAINER="${1:-}"

echo "=== MS-365 MCP Server — VM Setup ==="

# 1. Create the shared Docker network (safe to re-run)
if docker network ls --format '{{.Name}}' | grep -q "^ai-net$"; then
  echo "[SKIP] Docker network 'ai-net' already exists"
else
  echo "[CREATE] Creating Docker network 'ai-net'..."
  docker network create ai-net
fi

# 2. Connect AI app container to the network
if [ -n "$AI_CONTAINER" ]; then
  if docker network inspect ai-net --format '{{range .Containers}}{{.Name}} {{end}}' | grep -qw "$AI_CONTAINER"; then
    echo "[SKIP] '$AI_CONTAINER' is already connected to ai-net"
  else
    echo "[CONNECT] Connecting '$AI_CONTAINER' to ai-net..."
    docker network connect ai-net "$AI_CONTAINER"
  fi
else
  echo "[WARN] No AI container name provided. Run manually:"
  echo "       docker network connect ai-net <your-ai-container-name>"
fi

# 3. Check .env exists
if [ ! -f ".env" ]; then
  echo ""
  echo "[ACTION REQUIRED] No .env file found!"
  echo "  cp .env.example .env"
  echo "  Then fill in: MS365_MCP_CLIENT_ID, MS365_MCP_CLIENT_SECRET, MS365_MCP_TENANT_ID, MS365_MCP_PUBLIC_URL"
  echo ""
  exit 1
fi

# 4. Start the MCP server
echo "[START] Starting ms365-mcp container..."
docker compose pull
docker compose up -d

echo ""
echo "=== Done! ==="
echo "  Health check:    curl http://localhost:3000/"
echo "  Logs:            docker compose logs -f ms365-mcp"
echo "  MCP endpoint:    http://ms365-mcp:3000/mcp  (from other containers)"
echo "  MCP endpoint:    http://localhost:3000/mcp   (from host)"
echo ""
echo "  Connect in your AI app terminal:"
echo "    URL: http://ms365-mcp:3000/mcp"
echo "    Transport: streamable-http"
