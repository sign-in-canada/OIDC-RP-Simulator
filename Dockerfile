FROM node:lts-alpine
ENV NODE_ENV=production
WORKDIR /src
COPY package.json package-lock.json tsconfig.json config.ts ./
COPY . .
RUN npm install -g typescript
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
