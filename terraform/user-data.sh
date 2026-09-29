#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>&1) /var/log/user-data.err.log

# Update and install dependencies
apt-get update -y
apt-get install -y curl git nginx

# Install Node.js 20.x
curl -fsSL https://nodesource.com | bash -
apt-get install -y nodejs

# Install PM2 globally
npm install -g pm2

# Clone or place your application repository (example cloning a public repo)
cd /var/www
git clone https://github.com/KnightPrime/fullstack-app app
cd app/backend
npm install
pm2 start server.js --name "backend-api"

# Build React Frontend
cd ../frontend
npm install
npm run build

# Configure NGINX to serve React build and proxy /api requests to Node.js
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    root /var/www/app/frontend/build;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:5000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

systemctl restart nginx

