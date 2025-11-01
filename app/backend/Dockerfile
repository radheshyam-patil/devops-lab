FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "server.js"]
