FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY package.json package-lock.json* ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
