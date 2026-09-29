# --- Stage 1: Build the React Client ---
FROM node:20-alpine AS frontend-builder
WORKDIR /app
# Copy only package files first to leverage Docker layer caching
COPY frontend/package*.json ./frontend/
# FIXED: Changed from 'npm ci' to 'npm install'
RUN cd frontend && npm install
# Copy the rest of the frontend source code
COPY frontend/ ./frontend/
RUN cd frontend && npm run build

# --- Stage 2: Bundle Server Environment ---
FROM node:20-alpine
WORKDIR /app

# Install native NGINX package dependencies inside alpine
RUN apk add --no-cache nginx

# Configure and deploy background services
COPY backend/package*.json ./backend/
# FIXED: Changed from 'npm ci' to 'npm install'
RUN cd backend && npm install --only=production
COPY backend/ ./backend/

# Extract production compiled assets directly into the NGINX web root
COPY --from=frontend-builder /app/frontend/build /var/www/html
COPY nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 80

# Execute backend API asynchronously alongside the active NGINX process manager
CMD ["sh", "-c", "node backend/server.js & nginx -g 'daemon off;'"]
