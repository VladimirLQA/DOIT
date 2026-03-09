FROM node:20-slim AS builder

ENV APP_FOLDER=app

WORKDIR /$APP_FOLDER
COPY package.json ./
RUN npm i
COPY . .
RUN npm run build


FROM node:20-slim AS production

ENV APP_FOLDER=app
ENV NODE_ENV=production
ENV PORT=8086

WORKDIR /$APP_FOLDER
COPY package.json ./
COPY --from=builder /$APP_FOLDER/generated ./generated
COPY --from=builder /$APP_FOLDER/dist ./dist
RUN npm i --omit=dev \
    && chown -R node:node /$APP_FOLDER
USER node

EXPOSE $PORT
# CMD ["npm", "start"]   ← spawns an extra npm process
# CMD ["node", "dist/server.js"]  ← goes directly to node
CMD ["node", "dist/server.js"]