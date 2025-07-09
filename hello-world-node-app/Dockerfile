# ---- Base Node ----
FROM node:22 as build
WORKDIR /usr/src/app
COPY . .
RUN mkdir -p node_modules && npm install --only=production
RUN cp -R node_modules prod_node_modules

FROM node:22 AS release
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
USER node
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/prod_node_modules ./node_modules
COPY --from=build /usr/src/app/server.js ./server.js
COPY --from=build /usr/src/app/process.json ./process.json
EXPOSE 3000
CMD ["dumb-init", "node", "server.js"]
