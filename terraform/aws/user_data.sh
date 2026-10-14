#!/bin/bash
set -e

# Log all output to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Starting DevOps Resume Analyzer Deployment"
echo "=========================================="

# 1. Update OS and install prerequisites
if command -v dnf &> /dev/null; then
    # Amazon Linux 2023
    dnf update -y
    dnf install -y docker git curl jq
    systemctl enable --now docker
    usermod -aG docker ec2-user
    # Install Docker Compose binary & CLI plugin
    DOCKER_CONFIG=/usr/local/lib/docker/cli-plugins
    mkdir -p $DOCKER_CONFIG /usr/local/bin
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose $DOCKER_CONFIG/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
elif command -v apt-get &> /dev/null; then
    # Ubuntu
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg git jq
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
    usermod -aG docker ubuntu
    mkdir -p /usr/local/bin
    ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
fi

# 2. Retrieve EC2 Public IP using IMDSv2 with retry (allows Elastic IP association to settle)
PUBLIC_IP=""
for attempt in {1..12}; do
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
    if [ -n "$TOKEN" ]; then
        PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 || true)
    fi
    if [ -z "$PUBLIC_IP" ]; then
        PUBLIC_IP=$(curl -s --connect-timeout 2 https://checkip.amazonaws.com || true)
    fi
    if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "localhost" ]; then
        break
    fi
    sleep 3
done

if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP="localhost"
fi

echo "Detected Public IP: $PUBLIC_IP"

# 3. Clone Repository
APP_DIR="/opt/devops-resume-analyser"
rm -rf $APP_DIR
git clone -b ${repo_branch} ${repo_url} $APP_DIR
cd $APP_DIR

# 4. Generate environment variables
cat <<EOF > backend/.env
GROQ_API_KEY=${groq_api_key}
CORS_ORIGINS=http://localhost:3000,http://$PUBLIC_IP:3000
EOF

cat <<EOF > .env
NEXT_PUBLIC_BACKEND_URL=http://$PUBLIC_IP:8000
EOF

# 5. Launch containers via Docker Compose
echo "Building and launching containers..."
docker compose -f docker-compose.prod.yml up -d --build

# 6. Create systemd unit for persistence across reboots
cat <<EOF > /etc/systemd/system/resume-analyzer.service
[Unit]
Description=DevOps Resume Analyzer Stack
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable resume-analyzer.service

echo "=========================================="
echo "Deployment Complete!"
echo "Frontend:   http://$PUBLIC_IP:3000"
echo "Backend:    http://$PUBLIC_IP:8000"
echo "Prometheus: http://$PUBLIC_IP:9090"
echo "Grafana:    http://$PUBLIC_IP:3001"
echo "=========================================="
