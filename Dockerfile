FROM node:20-alpine AS builder

WORKDIR /unleash-proxy

COPY . .

RUN corepack enable

ENV YARN_ENABLE_SCRIPTS=false

RUN yarn install --immutable

RUN yarn build

RUN yarn workspaces focus -A --production

FROM node:20-alpine

# Upgrade (addresses CVE-2025-60876 and GHSA-vghf-hv5q-vc2g)
RUN apk update && \
    apk upgrade && \
    apk add busybox busybox-binsh ssl_client && \
    rm -rf /var/cache/apk/*

ENV NODE_ENV=production

WORKDIR /unleash-proxy

COPY --from=builder /unleash-proxy /unleash-proxy

RUN rm -rf /usr/local/lib/node_modules/npm/

RUN chown -R node:node /unleash-proxy

ENTRYPOINT ["/sbin/tini", "--"]

EXPOSE 3000

USER node

CMD ["./server.sh"]
