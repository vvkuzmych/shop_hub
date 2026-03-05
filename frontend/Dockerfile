# Development Dockerfile for ShopHub Frontend

FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy app files
COPY . .

# Expose Vite dev server port
EXPOSE 5175

# Start dev server (host and port configured in vite.config.ts)
CMD ["npm", "run", "dev"]
