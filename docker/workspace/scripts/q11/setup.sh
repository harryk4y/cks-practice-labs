#!/bin/bash
echo "[*] Setting up Q11 — Fix Dockerfile"
echo ""

mkdir -p /var/work/14/

cat > /var/work/14/Dockerfile <<'EOF'
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl wget
COPY app /app
USER root
ENTRYPOINT ["/app"]
EOF

echo "[✓] Dockerfile created at /var/work/14/Dockerfile"
echo ""
echo "Task:"
echo "  1. Fix the Dockerfile at /var/work/14/Dockerfile:"
echo "     - Change FROM to use ubuntu:20.04 (pinned version)"
echo "     - Change USER to 'myuser' (not root)"
echo "  2. Build the image using podman:"
echo "     podman build -t my-secure-app /var/work/14/"
echo ""
echo "Note: The image doesn't need to run successfully, just build."
