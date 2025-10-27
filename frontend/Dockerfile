# Stage 1: Build Angular app
FROM node:20-alpine AS build
WORKDIR /app

# Install deps (better layer caching)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine AS runtime
# Copy a simple SPA nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy built app (adjust path to angular.json outputPath)
COPY --from=build /app/dist/konecta-erp-frontend/browser /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]