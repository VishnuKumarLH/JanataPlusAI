# Stage 1: Build the application
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests
COPY package.json ./
COPY package-lock.json* ./

# Install all dependencies (including devDependencies)
RUN npm install

# Copy application source
COPY . .

# Run production build compilation (Vite + esbuild server compilation)
RUN npm run build

# Stage 2: Create lightweight production runner
FROM node:20-alpine AS runner

WORKDIR /app

# Set production environment flags
ENV NODE_ENV=production
ENV PORT=3000

# Copy manifests
COPY package.json ./
COPY package-lock.json* ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy built artifacts from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/data.json* ./

# Expose the default port
EXPOSE 3000

# Execute server using compiled entry point
CMD ["npm", "start"]
