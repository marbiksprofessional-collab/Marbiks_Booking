# 1. Base Build Environment Node Runtime Container Context
FROM node:18-alpine AS builder
WORKDIR /usr/src/app

# 2. Copy dependency configuration containers downstream
COPY package*.json ./
RUN npm install

# 3. Copy source files and execute production build compiler
COPY . .
RUN npm run build

# 4. Final runtime optimization phase loop parameters
FROM node:18-alpine
WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install --only=production

COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/.env ./.env

EXPOSE 3000
CMD ["npm", "run", "start:prod"]
