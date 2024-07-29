# Stage 1: Build the application
FROM node:19 AS builder

# Set the working directory
WORKDIR /app

# Install build tools for native dependencies
RUN apt-get update && apt-get install -y python3 make g++
 
# Copy the package.json and package-lock.json files
COPY package*.json ./

# Clean npm cache and install Nx CLI globally to ensure it is available
RUN npm cache clean --force
RUN npm install -g @nrwl/cli

# Install dependencies with no optional packages
RUN npm install

# Copy the rest of the application files
COPY . .

# Reset Nx cache and build the application
RUN npx nx reset
RUN npx nx build pt-notification-service

# Stage 2: Serve the application
FROM node:19-alpine

# Set the working directory
WORKDIR /app

# Copy the built application files from the builder stage
COPY --from=builder /app/dist/apps/pt-notification-service ./dist

# Install production dependencies with no optional packages
COPY package*.json ./
RUN npm install --only=production --no-optional

# Expose the port the app runs on
EXPOSE 3000

# Set memory limit for Node.js
ENV NODE_OPTIONS=--max-old-space-size=4096

# Start the application
CMD ["node", "dist/main.js"]
